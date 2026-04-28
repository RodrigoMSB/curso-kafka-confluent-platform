# Rúbrica de Evaluación - Lab 10

## Criterios

| Criterio | Peso |
|----------|------|
| 1. Schema Registry y compatibilidad | 20% |
| 2. Producir/consumir Avro | 15% |
| 3. Crear STREAM y TABLE en ksqlDB | 20% |
| 4. Persistent queries (filtros, agregaciones) | 25% |
| 5. JOIN end-to-end | 20% |

---

### 1. Schema Registry (20%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 18-20 | Registró v1, validó v2 compatible, validó v3 incompatible, articula BACKWARD vs FORWARD |
| Bueno | 14-17 | Operaciones correctas pero sin reflexión sobre compatibility modes |
| Suficiente | 10-13 | Solo registró schemas, no probó compatibility |
| Insuficiente | 0-9 | No completó |

### 2. Avro (15%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 14-15 | Produjo y consumió Avro, comparó con JSON, vio en Kafbat UI |
| Bueno | 11-13 | Produjo/consumió sin reflexión sobre tamaño |
| Suficiente | 8-10 | Solo produjo |
| Insuficiente | 0-7 | No completó |

### 3. STREAM y TABLE (20%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 18-20 | Creó ambos, articula diferencias, hizo queries con WHERE |
| Bueno | 14-17 | Creó ambos sin entender la diferencia conceptual |
| Suficiente | 10-13 | Solo creó STREAM |
| Insuficiente | 0-9 | No completó |

### 4. Persistent queries (25%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 23-25 | CREATE STREAM AS con filtro + agregación con ventana, midió tiempos |
| Bueno | 18-22 | Creó persistent queries pero sin agregación con ventana |
| Suficiente | 13-17 | Solo filtros simples |
| Insuficiente | 0-12 | No completó |

### 5. JOIN (20%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 18-20 | LEFT JOIN funcional, probó cliente inexistente, filtró VIPs |
| Bueno | 14-17 | JOIN funciona pero no probó casos edge |
| Suficiente | 10-13 | JOIN incompleto o devuelve nada |
| Insuficiente | 0-9 | No logró el JOIN |
