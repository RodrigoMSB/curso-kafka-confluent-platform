# Notas para el Instructor - Lab 10

## Distribución de tiempo sugerida

| Parte | Tiempo |
|-------|--------|
| Setup (imágenes ya pre-descargadas) | 10 min |
| Parte 1: Schema Registry | 30 min |
| Parte 2: Avro en acción | 20 min |
| Parte 3: ksqlDB fundamentos | 25 min |
| Parte 4: Desafío streaming SQL | 30 min |
| Discusión y cierre | 5 min |
| **Total** | **~120 min** |

---

## Antes de la clase

Pre-descargar imágenes en TODAS las máquinas:

```bash
docker pull confluentinc/cp-kafka:8.2.0
docker pull confluentinc/cp-schema-registry:8.2.0
docker pull confluentinc/cp-ksqldb-server:8.2.0
docker pull confluentinc/cp-ksqldb-cli:8.2.0
docker pull ghcr.io/kafbat/kafka-ui:latest
```

ksqlDB Server tarda 60-90s en arrancar. Es normal.

---

## Honestidad pedagógica obligatoria

Documentar EXPLÍCITAMENTE en clase:

1. **ksqlDB es genial para streaming SQL pero NO reemplaza a Kafka Streams (Java) en casos complejos.** Es una herramienta para analistas y data engineers que quieren prototipar rápido, no para reemplazar todo el código de procesamiento. Las queries persistent son aplicaciones Kafka Streams compiladas dinámicamente.

2. **En producción real, Schema Registry suele tener su propio cluster de alta disponibilidad** (3+ instancias detrás de un load balancer). Aquí usamos 1 instancia para simplicidad pedagógica.

3. **Las queries persistent en ksqlDB SON aplicaciones Kafka Streams compiladas dinámicamente.** Si quieres optimizar (custom serializers, cache local, lógica condicional compleja), eventualmente migras a Java.

4. **Nota sobre versiones**: el `cp-ksqldb-cli` se quedó en versión 8.0.3, mientras que `cp-ksqldb-server` está en 8.2.0. Esto es porque Confluent no publicó la imagen del CLI para Confluent Platform 8.2 (al menos hasta abril 2026). El CLI 8.0.3 es completamente compatible con servidores 8.x — solo es la herramienta cliente. Esto es típico en stacks Confluent: las imágenes "auxiliares" como CLIs a veces se quedan rezagadas. NO afecta funcionalidad.

---

## Puntos a enfatizar

### Parte 1
- **El "ahá" de compatibility**: cuando el alumno intenta registrar v3 y SR lo rechaza con 409 Conflict. Es el momento donde entiende que SR es un guardia activo, no solo un repositorio.
- **Subjects con sufijo `-value` y `-key`**: convención que confunde al inicio. Reforzar que es por defecto del `TopicNameStrategy`.

### Parte 2
- **Tamaño Avro vs JSON**: si tienen tiempo, mostrar con `kafkacat` o `tcpdump` el tamaño real del mensaje binario.
- **Validación pre-publicación**: el producer Avro VALIDA contra el schema antes de mandar al broker. Eso es un cambio de paradigma vs JSON suelto.

### Parte 3
- **STREAM vs TABLE**: el momento clave es cuando el alumno publica el cliente 1001 dos veces y ve que la TABLE muestra solo el último. Pausar y explicar.
- **`EMIT CHANGES`**: la primera vez que el alumno lo deja corriendo y produce algo en otra terminal viendo aparecer el evento en tiempo real es el "wow moment" del lab.

### Parte 4
- **Persistent query como aplicación**: explicar que cada `CREATE STREAM ... AS` lanza una aplicación Kafka Streams compilada al vuelo. Si vas a `docker logs ksqldb-server` puedes verlo.

---

## Errores comunes

| Error | Solución |
|-------|---------|
| Schema Registry no responde | Esperar 30-60s. Depende de los brokers, no arranca antes |
| `Subject not found` | El productor Avro creará el subject solo en la primera publicación |
| ksqlDB shell no conecta | Esperar más; ksqlDB tarda 60-90s en estar listo |
| `CREATE TABLE` falla con "key required" | El productor Avro de clientes debe enviar key (con `--property parse.key=true`) |
| JOIN no devuelve nada | Producir clientes ANTES de los pedidos. La TABLE debe tener datos cuando llegan los pedidos |
| `EMIT CHANGES` se queda colgado | Es por diseño. Ctrl+C para volver |
| Schema v3 se registra | Verificar que el compatibility level es BACKWARD (default), no NONE |

---

## Discusión grupal

1. **¿Schema Registry vs JSON Schema vs Protobuf?**
   - Avro: mejor para Kafka, integración nativa, evolución sólida
   - JSON Schema: más legible, pero más pesado
   - Protobuf: muy popular en gRPC, pero más complejo de usar

2. **¿Cuándo usar ksqlDB vs Flink vs Kafka Streams?**
   - ksqlDB: prototipos rápidos, equipos con SQL skills
   - Flink: alta complejidad, ML, requiere equipo data engineering
   - Kafka Streams: aplicaciones Java embebidas

3. **¿Cómo escalar ksqlDB en producción?**
   - Múltiples ksqlDB servers en mismo `service.id` (forman un cluster)
   - Las queries se distribuyen automáticamente entre nodos
   - State stores se replican
