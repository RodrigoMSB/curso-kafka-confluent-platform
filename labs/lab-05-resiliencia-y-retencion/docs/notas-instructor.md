# Notas para el Instructor - Lab 05

## Distribución de tiempo sugerida

| Parte | Tiempo |
|-------|--------|
| Setup (`start-lab.sh`) | 5 min |
| Parte 1: ISR bajo el microscopio | 25 min |
| Parte 2: Carrera contra MIR | 20 min |
| Parte 3: Recuperación y catch-up | 15 min |
| Parte 4: Retención en vivo | 25 min |
| Parte 5: Desafío (opcional) | 20 min |
| Discusión y cierre | 10 min |
| **Total** | **~120 min** |

---

## Antes de la clase

1. Pre-descargar imágenes:
   ```bash
   docker pull confluentinc/cp-kafka:8.2.0
   docker pull ghcr.io/kafbat/kafka-ui:latest
   ```

2. Asegurar que Labs 01-04 estén detenidos.

3. Tener Kafbat UI proyectada en pantalla durante toda la clase. Especialmente útil en Parte 1 (ver ISR cambiar) y Parte 4 (ver tamaño en disco).

---

## Puntos a enfatizar

### Parte 1
- **El ISR es dinámico**: cambia constantemente en producción. Que el alumno lo VEA cambiar al tumbar un broker es el momento clave.
- **Re-elección de líderes**: cuando muere el líder de una partición, KRaft elige otro entre el ISR. Casi instantáneo.

### Parte 2
- **Trade-off durabilidad vs disponibilidad**: este es el concepto más importante del lab. MIR alto = más durable pero menos tolerante a fallos.
- **`NotEnoughReplicasException`**: en producción real, los productores deben hacer retry exponencial. NO es un error fatal.

### Parte 3
- **Catch-up automático**: enfatizar que NO requiere intervención humana. Es por diseño.
- **El nuevo líder se mantiene**: KRaft no "devuelve" liderazgo automáticamente. Si quieres rebalancear, hay que ejecutar `kafka-leader-election --election-type PREFERRED`.

### Parte 4
- **Eliminación por SEGMENTO, no por mensaje**: clave conceptual. Un mensaje individual NO se borra; el segmento que lo contiene se borra cuando todos sus mensajes superan retention.
- **`segment.ms` corto en este lab**: lo bajamos a 10s para que el efecto sea observable. En producción típicamente 1h-1día.

### Parte 5
- **Compactación es asíncrona**: si el alumno no ve resultado inmediato, NO está roto. Explicar `min.cleanable.dirty.ratio` y que la compactación corre en background.
- **Tombstones**: el alumno suele creer que son "magia". Aclarar que es solo un mensaje con valor null que la compactación interpreta especial.

---

## Errores comunes de los alumnos

| Error | Solución |
|-------|---------|
| Confundir RF con MIR | RF = cuántas copias hay; MIR = cuántas deben confirmar para acks=all |
| "La compactación no funciona" | Es asíncrona, no instantánea. Esperar y volver a probar |
| Reset de líder al revivir | Kafka NO devuelve liderazgo. Es comportamiento normal |
| Producir al estricto y "no funciona" | Justamente: con 1 broker caído y MIR=3, NO funciona. Eso es lo que enseña el lab |

---

## Discusión grupal

1. **¿Por qué Kafka prefiere bloquear que perder durabilidad?**
   - Filosofía: mejor "no acepté tu mensaje" que "lo acepté y se perdió"
   - El productor sabe que falló y puede reintentar

2. **Si tienes 1000 brokers y RF=3, ¿qué MIR usarías?**
   - Sigue siendo MIR=2. Más brokers no cambia el cálculo por tópico (cada partición tiene RF réplicas).

3. **¿Cuándo NO usarías acks=all?**
   - Métricas/telemetría no críticas
   - Caso de uso "fire and forget"
   - Cuando latencia es más importante que durabilidad
