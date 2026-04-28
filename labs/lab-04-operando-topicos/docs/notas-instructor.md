# Notas para el Instructor - Lab 04

## Distribución de tiempo sugerida

| Parte | Tiempo |
|-------|--------|
| Setup (`start-lab.sh`) | 5 min |
| Parte 1: Anatomía | 15 min |
| Parte 2: Tópicos con personalidad | 25 min |
| Parte 3: Modificar en caliente | 15 min |
| Parte 4: Producción y consumo masivo | 25 min |
| Parte 5: Desafío (opcional) | 15 min |
| Discusión y cierre | 10 min |
| **Total** | **~110 min** |

---

## Antes de la clase

1. Pre-descargar imágenes:
   ```bash
   docker pull confluentinc/cp-kafka:8.2.0
   docker pull ghcr.io/kafbat/kafka-ui:latest
   ```
2. Asegurarse de que Labs 01, 02 y 03 estén detenidos.

---

## Puntos a enfatizar

### Parte 1
- **`__consumer_offsets`**: explicar que es un tópico Kafka usado por el propio Kafka. Meta-coolness.
- **`ConfigSource`**: el conceptual más importante del lab. Saber de dónde viene cada config.

### Parte 2
- **Compactación es asíncrona**: el alumno puede creer que falló porque ve los 5 mensajes inmediatamente. Aclarar que es por diseño.
- **`min.insync.replicas=3` con RF=3**: enfatizar que es la opción "máxima durabilidad / mínima disponibilidad". En producción real, casi nadie lo usa así.

### Parte 3
- **Aumentar particiones rompe orden por clave**: este es el "gotcha" #1 en producción. Si el alumno ya entendió esto, está listo para administrar Kafka real.
- **`--delete` de config**: enseñar que volver al default es legítimo, no un "bug".

### Parte 4
- **Throughput vs latencia**: el clásico tradeoff. `acks=all` da durabilidad a cambio de latencia.
- **`perf-test`**: es la herramienta oficial. Cuando alguien diga "Kafka es lento", usa esta para demostrar.

### Parte 5
- **Plan de reasignación JSON**: es operación quirúrgica. Solo hacer en producción con throttling.

---

## Errores comunes de los alumnos

| Error | Solución |
|-------|---------|
| Topic ya existe → falla create-topic | Usar `--if-not-exists` |
| Compactación no muestra resultados inmediatos | Explicar que es asíncrona |
| Reasignación JSON con sintaxis mala | Validar JSON antes de aplicar |
| `min.insync.replicas` mayor que brokers vivos | Explicar que el productor verá `NotEnoughReplicasException` |

---

## Discusión grupal

1. **¿Por qué Kafka no permite disminuir particiones ni cambiar RF con `--alter`?**
   - Ambos cambian la distribución física de datos. Cambiar partición rompe orden, cambiar RF requiere copiar datos masivamente.

2. **¿Qué `cleanup.policy` usarías para...**
   - Logs de aplicación → `delete` con retention corta
   - Estado de usuarios → `compact`
   - Eventos de pago → `delete` con retention larga (compliance)

3. **¿Cuándo usar `acks=0`?**
   - Métricas de telemetría donde perder algunas no importa
   - NUNCA para datos críticos
