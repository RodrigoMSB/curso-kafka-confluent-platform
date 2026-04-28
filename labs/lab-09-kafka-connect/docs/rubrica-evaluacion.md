# Rúbrica de Evaluación - Lab 09

## Criterios

| Criterio | Peso |
|----------|------|
| 1. Source connector creado y operativo (Parte 2) | 25% |
| 2. Sink connector creado y operativo (Parte 3) | 25% |
| 3. Flujo end-to-end demostrado (Parte 4) | 25% |
| 4. Comprensión arquitectónica (Parte 1) | 15% |
| 5. Conclusiones | 10% |

---

### 1. Source connector (25%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 23-25 | Source RUNNING, capturó pedidos seed + nuevos, midió latencia, articuló `incrementing` |
| Bueno | 18-22 | Source funcional pero sin reflexión sobre modos |
| Suficiente | 13-17 | Source creado pero con errores de configuración inicial |
| Insuficiente | 0-12 | No logró que el Source funcione |

### 2. Sink connector (25%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 23-25 | Sink RUNNING, escribió en `pedidos_procesados`, probó upsert, recuperó de mensaje malformado |
| Bueno | 18-22 | Sink funcional sin probar idempotencia |
| Suficiente | 13-17 | Sink creado, escribió pero sin entender upsert |
| Insuficiente | 0-12 | No logró que el Sink funcione |

### 3. Flujo end-to-end (25%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 23-25 | Insertó pedidos, vio en Kafka, publicó procesados, verificó en DB destino, midió tiempos |
| Bueno | 18-22 | Completó el flujo sin medir tiempos |
| Suficiente | 13-17 | Completó parcialmente |
| Insuficiente | 0-12 | No completó el desafío |

### 4. Arquitectura (15%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 14-15 | Articula Connector vs Task vs Worker, standalone vs distributed, tópicos `_connect-*` |
| Bueno | 11-13 | Comprensión correcta sin profundidad |
| Suficiente | 8-10 | Conceptos confusos pero parcialmente correctos |
| Insuficiente | 0-7 | No completó |

### 5. Conclusiones (10%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 9-10 | Compara Connect vs código custom, menciona Debezium, casos de uso reales |
| Bueno | 7-8 | Conclusiones correctas pero superficiales |
| Suficiente | 5-6 | Genéricas |
| Insuficiente | 0-4 | Sin conclusiones |
