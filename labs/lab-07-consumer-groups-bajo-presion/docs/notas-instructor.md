# Notas para el Instructor - Lab 07

## Distribución de tiempo sugerida

| Parte | Tiempo |
|-------|--------|
| Setup (`start-lab.sh`) | 5 min |
| Parte 1: Estrategias de asignación | 25 min |
| Parte 2: Lag y diagnóstico | 25 min |
| Parte 3: Rebalanceo | 20 min |
| Parte 4: Manejo manual de offsets | 20 min |
| Parte 5: Desafío DLQ (opcional) | 15 min |
| Discusión y cierre | 10 min |
| **Total** | **~120 min** |

---

## Antes de la clase

1. Pre-descargar imágenes:
   ```bash
   docker pull confluentinc/cp-kafka:8.2.0
   docker pull ghcr.io/kafbat/kafka-ui:latest
   ```
2. Asegurar que Labs 01-06 estén detenidos.
3. Tener Kafbat UI proyectada para mostrar el panel "Consumers" en vivo.

---

## Puntos a enfatizar

### Parte 1
- **El "antes y después" de Sticky**: agregar el 4to consumer es el momento clave. Mostrar al alumno que solo se mueven 2-3 particiones, no todas.
- **CooperativeSticky vs Sticky**: la diferencia operacional es enorme aunque parezca académica.

### Parte 2
- **Que el alumno VEA el lag subir y bajar**: el monitor en una terminal grande hace toda la diferencia pedagógica.
- **Bottleneck**: una vez que tienes 12 consumers para 12 particiones, agregar más es desperdicio.

### Parte 3
- **Diferencia tangible eager vs cooperative**: medir con cronómetro si es necesario.
- **"Stop-the-world"**: explicar por qué afecta SLA en sistemas con miles de mensajes/segundo.

### Parte 4
- **Skip sin DLQ es la "salida fácil" pero peligrosa**: enfatizar que en producción profesional NUNCA se hace sin DLQ.

### Parte 5
- **Headers que faltan en la DLQ simplificada**: puente al Capítulo 4 (donde se usan headers de Kafka).

---

## Errores comunes

| Error | Solución |
|-------|---------|
| "describe-group muestra el lag muy bajo" | Los consumers procesaron rápido; producir más con flood |
| "El reset falla con Group active" | Cerrar TODOS los consumers primero |
| "No veo el rebalanceo" | Cerrar bruscamente (Ctrl+C múltiple), no graceful |
| Monitor de lag muestra "-" en partición | Esa partición no tuvo commits aún |
| Consumer queda idle | Más consumers que particiones = ociosos esperados |

---

## Discusión grupal

1. **¿Por qué CooperativeSticky no es default históricamente?**
   - Es relativamente nuevo (Kafka 2.4+). Antes, eager era el único.
   - En Kafka moderno, deberías hacerlo default.

2. **¿Cuándo usarías Range?**
   - Casi nunca. Solo en casos donde necesitas **co-partitioning** entre múltiples tópicos (mismo consumer recibe partition N de varios tópicos).

3. **DLQ vs reintentos en memoria**:
   - Reintentos en memoria son rápidos pero pierden datos en crash.
   - DLQ es durable pero introduce latencia.
   - Patrón profesional: ambos. Reintentos en memoria 2-3 veces, después DLQ.
