# Notas para el Instructor - Lab 06

## Distribución de tiempo sugerida

| Parte | Tiempo |
|-------|--------|
| Setup (`start-lab.sh`) | 5 min |
| Parte 1: Tuning batch/linger | 25 min |
| Parte 2: Niveles de acks | 20 min |
| Parte 3: Idempotencia | 20 min |
| Parte 4: Transacciones | 25 min |
| Parte 5: Desafío (opcional) | 15 min |
| Discusión y cierre | 10 min |
| **Total** | **~120 min** |

---

## Antes de la clase

1. Pre-descargar imágenes:
   ```bash
   docker pull confluentinc/cp-kafka:8.2.0
   docker pull ghcr.io/kafbat/kafka-ui:latest
   ```
2. Asegurar que Labs 01-05 estén detenidos.
3. Tener claro que **las transacciones tienen una limitación pedagógica con CLI** (ver sección abajo).

---

## Limitación pedagógica de las transacciones

`kafka-console-producer` y `kafka-verifiable-producer` tienen soporte LIMITADO para control transaccional desde CLI. El control completo (`beginTransaction`, `commitTransaction`, `abortTransaction`) requiere código de aplicación con la API del cliente Kafka.

### Cómo manejarlo en clase

1. **Sé honesto**: explica que el lab muestra el CONCEPTO, no el control fino.
2. **Usa la limitación como puente**: "Para hacer esto bien en producción, necesitas un cliente Java/Python/Go, lo verán en sus proyectos".
3. **Lo que sí funciona perfecto**:
   - El concepto de `isolation.level=read_committed` vs `read_uncommitted`
   - La inspección con `kafka-transactions list/describe`
   - El requerimiento de `transactional.id` único

---

## Puntos a enfatizar

### Parte 1
- **Trade-off throughput vs latencia**: este es EL concepto del lab. Más batch = más throughput pero más latencia.
- **`linger.ms=0` es ineficiente**: muchos alumnos lo dejan así por miedo a "agregar latencia". Aclarar que 5-10ms es ganancia neta para casi todo workload.

### Parte 2
- **acks=0 es peligroso**: no es "fast", es "irresponsable". Solo para datos que pueden perderse.
- **acks=all NO ES un seguro contra todo**: si caen TODAS las réplicas en ISR antes del fsync, todavía se puede perder. La durabilidad real requiere `min.insync.replicas` también.

### Parte 3
- **Idempotencia es solo dentro de UN productor + UNA partición + UNA sesión**: este es el matiz crítico. Si el productor crashea y reinicia, hay duplicados.
- **`enable.idempotence=true` debería ser default en producción**: tiene cero costo a cambio de eliminar duplicados.

### Parte 4
- **Transacciones tienen overhead**: ~10-30% menos throughput por la coordinación.
- **`isolation.level=read_committed` introduce latencia**: el consumer espera al "End of Transaction Marker" antes de entregar mensajes.

### Parte 5
- **Hot partitioning** es el problema real de producción. Los VIPs siempre causan skew.

---

## Errores comunes

| Error | Solución |
|-------|---------|
| "El throughput no mejora con batch grande" | Verificar que `linger.ms > 0`; con 0, el batch nunca se llena |
| "Idempotencia no elimina mis duplicados" | Idempotencia es por sesión. Si reinicias el productor, hay nueva sesión |
| Producer falla con `ConfigException` | `enable.idempotence=true` requiere `acks=all` y `retries>0` |
| `kafka-transactions` no aparece | Imagen vieja; con cp-kafka:8.2.0 debe estar disponible |

---

## Discusión grupal

1. **Si el throughput sube linealmente con `batch.size`, ¿por qué no poner 100 MB?**
   - Latencia: el batch tarda en cerrarse
   - Memoria: cada batch ocupa RAM en el productor
   - Pérdida: si el productor cae con un batch grande, se pierde todo

2. **Idempotencia vs Transacciones: ¿cuál uso?**
   - Idempotencia: dedupe a nivel de productor (1 sesión, 1 partición)
   - Transacciones: exactly-once cross-partition + integración con consumer offsets

3. **¿Por qué `read_committed` no es default?**
   - Latencia: introduce delay al esperar el end-of-tx marker
   - Compatibilidad: la mayoría de los workloads no usa transacciones
