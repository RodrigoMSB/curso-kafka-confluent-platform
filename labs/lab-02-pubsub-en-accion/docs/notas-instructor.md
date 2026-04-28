# Notas para el Instructor - Lab 02

## Distribución de tiempo sugerida

| Parte | Tiempo | Descripción |
|-------|--------|-------------|
| Setup (`start-lab.sh`) | 5 min | Levantar clúster + crear tópico |
| Parte 1: Log inmutable | 15 min | Producir 5 mensajes, leer 2 veces |
| Parte 2: Pub/Sub | 15 min | 3 terminales reciben el mismo mensaje |
| Parte 3: Consumer Groups | 25 min | Escalar de 1 a 5 consumers, ver rebalanceo |
| Parte 4: Offsets y replay | 15 min | Reset de offsets, viaje en el tiempo |
| Parte 5: Desafío (opcional) | 15 min | Particionado por clave |
| Discusión grupal y cierre | 10 min | Mapeo a casos reales |
| **Total** | **~100 min** | |

---

## Antes de la clase

1. Pre-descargar imágenes (si no se ejecutó el Lab 01 antes):
   ```bash
   docker pull confluentinc/cp-kafka:8.2.0
   docker pull ghcr.io/kafbat/kafka-ui:latest
   ```

2. Tener Kafbat UI abierta en el proyector durante toda la clase. Es clave para que los alumnos vean el rebalanceo en vivo.

3. Asegurarse de que el Lab 01 NO esté corriendo (los puertos chocan). Ejecutar `bin/stop-lab.sh` desde el Lab 01 antes.

---

## Puntos a enfatizar durante el laboratorio

### Durante la Parte 1
- **Inmutabilidad**: el momento donde el alumno lee los mismos mensajes 2 veces es el "ahá" pedagógico clave. Detenerse a explicar la diferencia con RabbitMQ.
- **Sin `--from-beginning`**: muchos alumnos olvidan este flag y creen que "no hay mensajes". Aclarar que el comportamiento por defecto es "solo nuevos".

### Durante la Parte 2
- **Pub/Sub vs Cola**: dibujar en pizarrón:
  - Cola (RabbitMQ): 1 mensaje → 1 consumidor
  - Log (Kafka): 1 mensaje → N consumidores independientes

### Durante la Parte 3
- **El momento mágico**: lanzar el segundo consumidor y ver el rebalanceo en Kafbat UI. Resaltar que Kafka lo hace automáticamente.
- **Cota máxima**: con más consumidores que particiones, los demás se quedan ociosos. Argumentar por qué definir bien la cantidad de particiones al diseñar.

### Durante la Parte 4
- **Aislamiento de grupos**: enfatizar que cada grupo tiene SU PROPIA realidad de offsets. Es como si cada uno tuviera su propio puntero al log.
- **Reset cuando NO hay consumidores activos**: si hay un consumidor activo cuando ejecutas reset, falla. Explicar por qué (Kafka lo previene para evitar inconsistencias).

### Durante la Parte 5
- **Hash murmur2 vs cksum**: el script de predicción usa una aproximación. Es honestidad pedagógica explicarlo y mostrar que la verdad está en Kafbat UI.

---

## Errores comunes de los alumnos

### Conceptuales

| Error | Cómo guiar |
|-------|-----------|
| Confundir consumer group con consumer | El consumer es 1 proceso. El grupo es la "etiqueta lógica" que comparten varios consumers para colaborar |
| Creer que sin grupo no hay consumo | Sin grupo se consume igual, solo que cada uno es independiente |
| Pensar que el reset afecta a todos los grupos | Explicar que cada grupo es soberano sobre sus offsets |
| Creer que más particiones = más rendimiento siempre | Más particiones tiene costos: más overhead, más metadata, más coordinación |

### Técnicos

| Error | Solución |
|-------|---------|
| `Reset failed: There are still consumers active` | Asegurarse de hacer Ctrl+C en TODAS las terminales del grupo antes de resetear |
| Consumer no recibe mensajes históricos | Faltó `--from-beginning` o el grupo ya tiene offsets posteriores guardados |
| Kafbat UI no muestra grupos | Refrescar la pestaña; los grupos efímeros (sin --group) no aparecen |
| Múltiples grupos con el mismo nombre por error | Usar nombres descriptivos como `dashboard`, `alertas`, `reportes` |

---

## Preguntas para discusión grupal

1. **¿Por qué Kafka eligió ser un log y no una cola?**
   - Respuesta: re-procesabilidad, múltiples consumidores, almacenamiento durable, separación entre producción y consumo.

2. **Si tuvieras un sistema con 1000 vehículos enviando 100 eventos/seg cada uno, ¿cuántas particiones diseñarías?**
   - Discusión: depende del paralelismo deseado. Si cada partición soporta ~10K msg/seg de procesamiento, 100K msg/seg requieren ~10 particiones mínimo, con margen → 12-20.

3. **¿Cuándo NO querrías usar consumer groups?**
   - Respuesta: cuando quieres que múltiples sistemas independientes vean TODOS los mensajes (broadcast). Cada sistema debería tener su propio grupo, y dentro de cada grupo poner consumers para escalar.

---

## Extensiones posibles (si hay tiempo)

- Mostrar `__consumer_offsets` (el tópico interno donde Kafka guarda los offsets de los grupos)
- Reset a un offset específico (`--to-offset N`) en lugar de `--to-earliest`
- Reset por timestamp (`--to-datetime`)
- Mostrar `auto.offset.reset` y la diferencia entre `earliest` y `latest`
