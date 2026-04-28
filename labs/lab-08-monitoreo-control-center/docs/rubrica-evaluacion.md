# Rúbrica de Evaluación - Lab 08

## Criterios

| Criterio | Peso |
|----------|------|
| 1. Arquitectura entendida (Parte 1) | 15% |
| 2. Tour Control Center (Parte 2) | 20% |
| 3. Métricas bajo carga (Parte 3) | 20% |
| 4. Alerta funcional (Parte 4) | 25% |
| 5. Comparativa Kafbat vs CC (Parte 5) | 15% |
| 6. Conclusiones | 5% |

---

### 1. Arquitectura (15%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 14-15 | Identifica `cp-server` vs `cp-kafka`, articula flujo OTLP, explica falla independiente de cada componente |
| Bueno | 11-13 | Verificó las UIs pero no profundizó en arquitectura |
| Suficiente | 8-10 | Solo verificó que las URLs respondan |
| Insuficiente | 0-7 | No completó |

### 2. Tour CC (20%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 18-20 | Llenó tablas de brokers, tópicos, consumers; capturó pantallas |
| Bueno | 14-17 | Tablas completas sin pantallazos |
| Suficiente | 10-13 | Tablas parciales |
| Insuficiente | 0-9 | No completó |

### 3. Métricas bajo carga (20%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 18-20 | Generó carga, observó throughput en CC, comparó con Kafbat UI |
| Bueno | 14-17 | Generó carga sin comparar |
| Suficiente | 10-13 | Solo dejó la carga corriendo |
| Insuficiente | 0-9 | No completó |

### 4. Alerta funcional (25%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 23-25 | Creó trigger en CC, lo disparó tumbando un broker, verificó en Alert History, midió tiempo |
| Bueno | 18-22 | Alerta creada y disparada pero verificación parcial |
| Suficiente | 13-17 | Solo creó la alerta, no la disparó |
| Insuficiente | 0-12 | No completó |

### 5. Comparativa (15%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 14-15 | Tabla completa + decisiones por caso + reflexión sobre uso simultáneo |
| Bueno | 11-13 | Tabla completa sin reflexión |
| Suficiente | 8-10 | Tabla parcial |
| Insuficiente | 0-7 | No completó |

### 6. Conclusiones (5%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 5 | 3-5 frases con insights propios |
| Bueno | 3-4 | Conclusiones correctas |
| Suficiente | 2 | Genéricas |
| Insuficiente | 0-1 | Sin conclusiones |
