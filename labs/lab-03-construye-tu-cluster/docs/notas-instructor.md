# Notas para el Instructor - Lab 03

## Distribución de tiempo sugerida

| Parte | Tiempo | Descripción |
|-------|--------|-------------|
| Parte 1: Anatomía de la imagen | 15 min | Inspección, exploración |
| Parte 2: Primer broker solitario | 25 min | Plantilla con TODOs, levantar 1 broker |
| Parte 3: Creciendo a 3 brokers | 20 min | Replicar bloques, levantar quorum |
| Parte 4: Chequeo de salud KRaft | 15 min | `kafka-metadata-quorum`, simular fallos |
| Parte 5: Desafío (opcional) | 15 min | Listeners separados |
| Discusión grupal y cierre | 10 min | Mapeo a producción |
| **Total** | **~100 min** | |

---

## Antes de la clase

1. Pre-descargar imagen:
   ```bash
   docker pull confluentinc/cp-kafka:8.2.0
   ```

2. Asegurar que los Labs 01 y 02 estén detenidos en las máquinas de los alumnos. Los puertos chocan (9092-9094).

3. Tener un terminal grande visible en el proyector para mostrar `bin/check-quorum.sh` en vivo.

---

## Puntos a enfatizar

### Durante la Parte 1
- **No es burocracia**: explorar la imagen ayuda a desmitificar Kafka. No es magia, son binarios y archivos de config.

### Durante la Parte 2
- **Storage formatting**: muchos alumnos saltarán este paso o lo entenderán mal. Detenerse y explicar que `kafka-storage format` es como `mkfs` en un disco virgen: prepara el filesystem para Kafka.
- **CLUSTER_ID**: es la identidad del clúster. Cambia uno solo y los brokers no se reconocen.

### Durante la Parte 3
- **Ejercicio de detective**: el alumno debe replicar el patrón. Esto fija el aprendizaje. Si simplemente copia/pega de la solución, no entiende por qué cada broker tiene puertos distintos.
- **Quorum**: enfatizar que es **el mismo** valor en los 3 brokers, no uno distinto.

### Durante la Parte 4
- **Matar al líder**: el ejercicio de `docker stop` y ver la re-elección es uno de los más memorables. Aprovechar para discutir tolerancia a fallos.

### Durante la Parte 5
- **Solo si hay tiempo**: este desafío profundiza, pero el alumno puede saltarlo si va apretado.

---

## Errores comunes de los alumnos

### Conceptuales

| Error | Cómo guiar |
|-------|-----------|
| Confundir `node.id` con `cluster.id` | Node = identidad del broker; Cluster = identidad del clúster compartida |
| Pensar que KRaft requiere ZooKeeper | Explicar que KRaft REEMPLAZA a ZK, no convive |
| Creer que `replication.factor=3` siempre se puede | Solo si hay al menos 3 brokers vivos |

### Técnicos

| Error | Solución |
|-------|---------|
| Broker no arranca: "Cluster ID required" | Falta formatear storage o pasar CLUSTER_ID en env |
| `Address already in use` | Lab 01 o Lab 02 todavía corriendo. `docker ps` y stop |
| Solo 2 brokers ven el quorum | El tercer broker tiene CLUSTER_ID o QUORUM_VOTERS distinto |
| Cliente desde host no se conecta | EXTERNAL listener mal configurado (advertised) |

---

## Preguntas para discusión grupal

1. **¿Por qué Apache eliminó ZooKeeper en Kafka 4?**
   - Simplificación operativa, una sola tecnología que mantener, mejor rendimiento, eliminación de un punto de fallo independiente.

2. **¿Cuántos controllers son recomendados en producción?**
   - Para tolerancia a fallos: 3 o 5 (impar). Con 3, soportas la pérdida de 1.

3. **¿Qué pasa si pierdes la mayoría del quorum (ej: 2 de 3 brokers controller)?**
   - El clúster queda en read-only. No se pueden tomar decisiones de control hasta recuperar quorum.
