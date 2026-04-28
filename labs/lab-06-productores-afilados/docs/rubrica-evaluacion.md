# Rúbrica de Evaluación - Lab 06

## Criterios

| Criterio | Peso |
|----------|------|
| 1. Tuning batch/linger (Parte 1) | 25% |
| 2. Niveles de acks (Parte 2) | 20% |
| 3. Idempotencia (Parte 3) | 20% |
| 4. Transacciones (Parte 4) | 25% |
| 5. Conclusiones | 10% |
| 6. Desafío de particionado (Parte 5) | 10% (bono) |

---

### 1. Tuning (25%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 23-25 | Llenó todas las tablas con métricas reales, comparó configs, articuló trade-offs |
| Bueno | 18-22 | Tablas completas pero sin reflexión profunda |
| Suficiente | 13-17 | Solo midió baseline y una variante |
| Insuficiente | 0-12 | No completó las mediciones |

### 2. Niveles de acks (20%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 18-20 | Comparó los 3 niveles, justificó casos de uso |
| Bueno | 14-17 | Comparó los 3 sin justificación |
| Suficiente | 10-13 | Solo probó 1-2 niveles |
| Insuficiente | 0-9 | No completó |

### 3. Idempotencia (20%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 18-20 | Probó naive vs idempotente, articuló los matices (1 sesión, 1 partición) |
| Bueno | 14-17 | Hizo el experimento sin entender los matices |
| Suficiente | 10-13 | Solo probó idempotente |
| Insuficiente | 0-9 | No completó |

### 4. Transacciones (25%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 23-25 | Probó commit y abort, comparó isolation levels, inspeccionó transacciones |
| Bueno | 18-22 | Probó commit pero no abort |
| Suficiente | 13-17 | Solo entendió el concepto sin probarlo |
| Insuficiente | 0-12 | No completó |

### 5. Conclusiones (10%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 9-10 | 3-5 frases con insights propios |
| Bueno | 7-8 | Conclusiones correctas pero superficiales |
| Suficiente | 5-6 | Conclusiones genéricas |
| Insuficiente | 0-4 | Sin conclusiones |

### 6. Desafío (bono 10%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 9-10 | Hot partitioning + reflexión sobre soluciones |
| Bueno | 7-8 | Probó particionado pero sin reflexión |
| Suficiente | 5-6 | Solo hizo Reto 1 |
| Insuficiente | 0-4 | No intentó |
