# Rúbrica de Evaluación - Lab 07

## Criterios

| Criterio | Peso |
|----------|------|
| 1. Estrategias de asignación (Parte 1) | 25% |
| 2. Lag y diagnóstico (Parte 2) | 20% |
| 3. Rebalanceo (Parte 3) | 20% |
| 4. Manejo manual de offsets (Parte 4) | 20% |
| 5. Conclusiones | 10% |
| 6. Desafío DLQ (Parte 5) | 10% (bono) |

---

### 1. Estrategias (25%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 23-25 | Probó las 4 estrategias, comparó Sticky vs CooperativeSticky, articuló cuándo usar cada una |
| Bueno | 18-22 | Probó las 4 sin profundizar |
| Suficiente | 13-17 | Solo 2-3 estrategias |
| Insuficiente | 0-12 | No completó |

### 2. Lag (20%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 18-20 | Generó lag, escaló consumers, observó el comportamiento con N>particiones |
| Bueno | 14-17 | Hizo el flood pero no exploró el límite |
| Suficiente | 10-13 | Solo monitoreó el lag inicial |
| Insuficiente | 0-9 | No completó |

### 3. Rebalanceo (20%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 18-20 | Midió tiempo de ambas estrategias, observó "stop-the-world" |
| Bueno | 14-17 | Probó pero sin medir tiempos exactos |
| Suficiente | 10-13 | Solo eager o solo cooperative |
| Insuficiente | 0-9 | No completó |

### 4. Offsets (20%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 18-20 | Probó timestamp + offset específico + skip, articuló cuándo usar cada uno |
| Bueno | 14-17 | Hizo 2 de 3 |
| Suficiente | 10-13 | Solo 1 |
| Insuficiente | 0-9 | No completó |

### 5. Conclusiones (10%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 9-10 | Insights propios sobre operación |
| Bueno | 7-8 | Conclusiones correctas |
| Suficiente | 5-6 | Genéricas |
| Insuficiente | 0-4 | Sin conclusiones |

### 6. Desafío DLQ (bono 10%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 9-10 | Implementó DLQ + reflexión sobre headers + loop infinito |
| Bueno | 7-8 | Implementó DLQ sin reflexión profunda |
| Suficiente | 5-6 | Solo separó mensajes |
| Insuficiente | 0-4 | No intentó |
