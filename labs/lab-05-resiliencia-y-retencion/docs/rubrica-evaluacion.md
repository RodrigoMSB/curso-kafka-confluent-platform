# Rúbrica de Evaluación - Lab 05

## Criterios

| Criterio | Peso |
|----------|------|
| 1. ISR bajo el microscopio (Parte 1) | 20% |
| 2. Carrera contra MIR (Parte 2) | 25% |
| 3. Recuperación y catch-up (Parte 3) | 15% |
| 4. Retención en vivo (Parte 4) | 20% |
| 5. Conclusiones | 10% |
| 6. Desafío de compactación (Parte 5) | 10% (bono) |

---

### 1. ISR (20%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 18-20 | Tabla ISR completa, observó cambio al tumbar broker, distinguió follower vs líder |
| Bueno | 14-17 | Tabla completa pero no observó re-elección |
| Suficiente | 10-13 | Tabla incompleta |
| Insuficiente | 0-9 | No completó |

### 2. MIR (25%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 23-25 | Provocó NotEnoughReplicasException, comparó con resiliente, articuló trade-off |
| Bueno | 18-22 | Hizo el experimento pero sin reflexión sobre trade-off |
| Suficiente | 13-17 | Solo probó uno de los dos tópicos |
| Insuficiente | 0-12 | No completó |

### 3. Recuperación (15%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 14-15 | Midió tiempo de catch-up, verificó no pérdida de mensajes |
| Bueno | 11-13 | Hizo el experimento sin medición precisa |
| Suficiente | 8-10 | No verificó que mensajes no se perdieran |
| Insuficiente | 0-7 | No completó |

### 4. Retención (20%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 18-20 | Vio eliminación efectiva, comparó tamaños en Kafbat UI |
| Bueno | 14-17 | Vio eliminación pero sin comparar tamaños |
| Suficiente | 10-13 | No vio eliminación efectiva (común si solo produjo una vez) |
| Insuficiente | 0-9 | No completó |

### 5. Conclusiones (10%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 9-10 | Articula trade-offs con ejemplos propios |
| Bueno | 7-8 | Conclusiones correctas pero superficiales |
| Suficiente | 5-6 | Conclusiones genéricas |
| Insuficiente | 0-4 | Sin conclusiones |

### 6. Desafío (bono 10%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 9-10 | Compactación + tombstone + reflexión completa |
| Bueno | 7-8 | Compactación + tombstone sin reflexión |
| Suficiente | 5-6 | Solo compactación |
| Insuficiente | 0-4 | No intentó |
