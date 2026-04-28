# Rúbrica de Evaluación - Lab 02

## Criterios de evaluación

| Criterio | Peso |
|----------|------|
| 1. Comprensión del log inmutable (Parte 1) | 15% |
| 2. Comprensión del modelo pub/sub (Parte 2) | 15% |
| 3. Manejo de consumer groups (Parte 3) | 25% |
| 4. Manejo de offsets y replay (Parte 4) | 25% |
| 5. Calidad de las conclusiones | 10% |
| 6. Desafío de particionado (Parte 5) | 10% (bono opcional) |

---

### 1. Log inmutable (15%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| **Excelente** | 14-15 | Identifica que los mensajes no se borran. Distingue claramente el comportamiento con/sin `--from-beginning`. Conecta con el concepto de offset |
| **Bueno** | 11-13 | Identifica la inmutabilidad pero le falta precisión en algún detalle |
| **Suficiente** | 8-10 | Reconoce la inmutabilidad pero confunde el comportamiento de offsets |
| **Insuficiente** | 0-7 | No completó las actividades o las respuestas son incorrectas |

### 2. Pub/Sub (15%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| **Excelente** | 14-15 | Reconoce que múltiples consumers SIN grupo reciben todo. Compara correctamente con RabbitMQ |
| **Bueno** | 11-13 | Reconoce el comportamiento pero la comparación con cola tradicional es vaga |
| **Suficiente** | 8-10 | Completó pero no logró articular la diferencia conceptual |
| **Insuficiente** | 0-7 | Confunde el comportamiento o no completó |

### 3. Consumer Groups (25%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| **Excelente** | 23-25 | Llenó las tablas de distribución correctamente. Observó el rebalanceo. Identifica el límite de consumers vs particiones |
| **Bueno** | 18-22 | Completó la mayoría pero le faltan detalles del rebalanceo o del ocioso |
| **Suficiente** | 13-17 | Solo lanzó algunos consumers, no exploró el límite |
| **Insuficiente** | 0-12 | No completó el experimento |

### 4. Offsets y replay (25%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| **Excelente** | 23-25 | Reset exitoso. Verificó aislamiento entre grupos. Tabla de offsets antes/después correcta |
| **Bueno** | 18-22 | Hizo el reset pero no verificó aislamiento entre grupos |
| **Suficiente** | 13-17 | El reset falló por consumers activos pero después lo logró |
| **Insuficiente** | 0-12 | No logró completar el reset |

### 5. Conclusiones (10%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| **Excelente** | 9-10 | Articula los 3 conceptos clave (log inmutable, pub/sub, consumer groups) con ejemplos propios |
| **Bueno** | 7-8 | Articula los conceptos pero sin ejemplos propios |
| **Suficiente** | 5-6 | Conclusiones genéricas |
| **Insuficiente** | 0-4 | Sin conclusiones o incorrectas |

### 6. Desafío (10%, opcional como bono)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| **Excelente** | 9-10 | Predicciones, verificación en Kafbat UI, y reflexión sobre 100 vehículos completos |
| **Bueno** | 7-8 | Verificación correcta pero reflexión incompleta |
| **Suficiente** | 5-6 | Solo hizo la verificación, sin reflexión |
| **Insuficiente** | 0-4 | No intentó el desafío |
