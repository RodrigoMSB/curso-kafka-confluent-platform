# Notas del instructor - Lab 01: Radiografía de un clúster Kafka vivo

## Distribución de tiempo sugerida

| Actividad | Duración | Notas |
|-----------|----------|-------|
| Levantar entorno | 20 min | Incluye descarga de imágenes Docker si es la primera vez |
| Parte 1: Exploración del clúster | 25 min | Los alumnos deben tomarse tiempo para entender cada comando |
| Parte 2: Mapeo arquitectónico | 20 min | Puede hacerse en papel si no hay acceso a draw.io |
| Parte 3: Tolerancia a fallos | 25 min | Actividad más impactante - dedicarle tiempo |
| Parte 4: Desafío extra | 15 min | Opcional, para alumnos avanzados |
| Cierre y discusión grupal | 15 min | Compartir hallazgos, resolver dudas |
| **Total** | **~120 min** | |

---

## Antes de la clase

1. **Probar el laboratorio completo** en tu máquina al menos una vez
2. Verificar que las imágenes Docker se descargan correctamente (la primera descarga puede tardar ~10 minutos)
3. Tener preparado un terminal adicional para mostrar en pantalla
4. Si la red del aula es lenta, considerar pre-descargar las imágenes:
   ```bash
   docker pull confluentinc/cp-kafka:8.2.0
   docker pull ghcr.io/kafbat/kafka-ui:latest
   ```

> **Recomendación**: Para el despliegue en clase, pinear `ghcr.io/kafbat/kafka-ui` a una versión específica (ver https://github.com/kafbat/kafka-ui/releases) y actualizar `infra/.env` con el tag exacto. El uso de `latest` es solo para desarrollo del laboratorio.

---

## Puntos a enfatizar durante el laboratorio

### Durante la Parte 1 (Exploración)

- **KRaft vs. ZooKeeper**: Explicar que Kafka 4.2 (y desde Kafka 4.0 en general) ya no usa ZooKeeper. El quorum de controladores es interno.
- **Diferencia entre listeners**: PLAINTEXT (inter-broker), EXTERNAL (clientes), CONTROLLER (quorum KRaft). Mostrar por qué hay múltiples listeners.
- **Particiones como unidad de paralelismo**: Cada partición es un log ordenado e inmutable. 6 particiones = hasta 6 consumidores en paralelo.
- **ISR (In-Sync Replicas)**: Son las réplicas que están "al día" con el líder. Solo ellas pueden ser elegidas como nuevo líder.

### Durante la Parte 2 (Mapeo)

- **Distribución de líderes**: Kafka intenta distribuir líderes equitativamente entre los brokers (preferred replica election).
- **Factor de replicación**: Con RF=3 y 3 brokers, cada partición existe en TODOS los brokers. Con más brokers, la distribución sería diferente.
- **El productor no sabe de particiones internas**: Desde la perspectiva del productor, envía al tópico. Kafka decide a qué partición va cada mensaje.

### Durante la Parte 3 (Tolerancia a fallos)

- **Elección de líder es automática**: No requiere intervención manual. Kafka detecta la caída y elige un nuevo líder de entre las ISR.
- **min.insync.replicas=2**: Con esta configuración y RF=3, el clúster tolera la caída de 1 broker sin perder la capacidad de escritura. Si cayeran 2, el productor recibiría errores.
- **El broker recuperado no recupera liderazgo automáticamente** (por defecto): Explicar `auto.leader.rebalance.enable` y por qué puede ser mejor no activarlo en producción.
- **No se pierden datos confirmados**: Los datos que ya fueron replicados a las ISR están seguros. Solo se podrían perder datos que estaban solo en el broker caído y que aún no se habían replicado.

---

## Errores comunes de los alumnos

### Conceptuales

| Error | Cómo guiar |
|-------|-----------|
| Confundir "partición" con "réplica" | Una partición es un log. Cada partición tiene 1 líder y N-1 réplicas. La réplica es una copia de la partición. |
| Creer que el controlador es un "super broker" | El controlador gestiona metadatos y elecciones. No tiene privilegios especiales sobre los datos. |
| Pensar que ISR=3 siempre | ISR puede reducirse cuando un broker cae o se atrasa. El tamaño ideal de ISR = factor de replicación. |
| Creer que al tumbar un broker se pierden datos | Aclarar que los datos están replicados. Solo se pierden si caen tantos brokers que no queda ninguna ISR. |
| Confundir "lag" del consumidor con "pérdida" | Lag = diferencia entre último mensaje producido y último consumido. No implica pérdida, solo retraso. |

### Técnicos

| Error | Solución |
|-------|---------|
| Los scripts no tienen permisos de ejecución | `chmod +x bin/*.sh kafka-cli/*.sh` |
| "Cannot connect to bootstrap server" | Verificar que los contenedores están corriendo con `docker ps` |
| Kafbat UI no carga | Esperar ~30 segundos, verificar con `docker logs kafbat-ui` |
| El alumno ejecuta comandos Kafka en el host | Los comandos CLI deben ejecutarse dentro del contenedor (los scripts ya lo hacen) |

---

## Qué observar en las respuestas

### Indicadores de buena comprensión

- El alumno identifica correctamente los roles de cada componente
- Puede explicar la relación entre particiones, líderes e ISR con sus propias palabras
- En tolerancia a fallos, nota que el productor siguió funcionando
- Las conclusiones mencionan la importancia de la replicación para la durabilidad
- El diagrama muestra correctamente la distribución de líderes y réplicas

### Señales de alerta (requieren refuerzo)

- El alumno copia y pega la salida del comando sin interpretar
- No distingue entre líder y réplica en su diagrama
- No puede explicar qué pasaría si cayeran 2 de 3 brokers
- Las conclusiones son genéricas ("Kafka es resiliente") sin evidencia específica

---

## Preguntas para la discusión grupal

1. ¿Qué pasaría si `min.insync.replicas` fuera 3 en lugar de 2?
2. ¿Cuál es el número máximo de brokers que pueden caer simultáneamente sin perder datos?
3. ¿Por qué Kafka eligió al broker X como nuevo líder y no al Y?
4. ¿En qué escenarios reales podría caer un broker? (hardware, red, actualizaciones)
5. ¿Qué ventajas tiene KRaft sobre ZooKeeper para este tipo de escenarios?

---

## Extensiones posibles

Si el grupo es avanzado y termina antes de tiempo:

1. **Tumbar 2 brokers**: Observar que el productor falla con `NotEnoughReplicasException`
2. **Cambiar `min.insync.replicas`**: Modificar la configuración en caliente y observar el efecto
3. **Consumer groups con múltiples consumidores**: Abrir 3 terminales consumiendo del mismo grupo y observar la distribución de particiones

---

*Notas del instructor - Lab 01*
