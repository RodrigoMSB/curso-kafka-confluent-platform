# Rúbrica de Evaluación - Lab 04

## Criterios

| Criterio | Peso |
|----------|------|
| 1. Anatomía de tópicos (Parte 1) | 15% |
| 2. Configuración de tópicos especializados (Parte 2) | 30% |
| 3. Modificación en caliente (Parte 3) | 20% |
| 4. Producción y consumo masivo (Parte 4) | 25% |
| 5. Conclusiones | 10% |
| 6. Desafío de RF y eliminación (Parte 5) | 10% (bono) |

---

### 1. Anatomía (15%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 14-15 | Identifica `ConfigSource`, distingue interno vs visible, conceptualiza `__consumer_offsets` |
| Bueno | 11-13 | Completa pero sin claridad en jerarquía de configs |
| Suficiente | 8-10 | Listó tópicos pero no entendió configs |
| Insuficiente | 0-7 | No completó |

### 2. Tópicos con personalidad (30%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 27-30 | Los 4 tópicos creados con configs correctas, justifica cada decisión |
| Bueno | 21-26 | 4 tópicos creados pero sin justificar todas las configs |
| Suficiente | 15-20 | Solo 2-3 tópicos completos |
| Insuficiente | 0-14 | Solo 1 tópico o ninguno |

### 3. Modificar en caliente (20%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 18-20 | Entendió DYNAMIC vs DEFAULT, probó disminuir particiones intencionalmente |
| Bueno | 14-17 | Hizo los cambios pero sin entender ConfigSource |
| Suficiente | 10-13 | Solo cambió retention, no probó particiones |
| Insuficiente | 0-9 | No completó |

### 4. Producción masiva (25%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| Excelente | 23-25 | Comparó `acks=all` vs `acks=1`, midió latencia, consumió por partición |
| Bueno | 18-22 | Hizo perf-test pero no comparó configs |
| Suficiente | 13-17 | Solo produjo masivamente, no midió ni comparó |
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
| Excelente | 9-10 | Cambió RF con plan, articula riesgos |
| Bueno | 7-8 | Cambió RF pero sin reflexión |
| Suficiente | 5-6 | Solo eliminó tópico |
| Insuficiente | 0-4 | No intentó |
