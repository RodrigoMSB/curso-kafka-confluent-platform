# Rúbrica de Evaluación - Lab 03

## Criterios de evaluación

| Criterio | Peso |
|----------|------|
| 1. Inspección de imagen (Parte 1) | 10% |
| 2. Configuración del broker solitario (Parte 2) | 25% |
| 3. Configuración del clúster de 3 brokers (Parte 3) | 30% |
| 4. Análisis del quorum KRaft (Parte 4) | 25% |
| 5. Calidad de las conclusiones | 10% |
| 6. Desafío de listeners (Parte 5) | 10% (bono opcional) |

---

### 1. Inspección (10%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| **Excelente** | 9-10 | Listó binarios, identificó archivos de config, anotó versión Java correctamente |
| **Bueno** | 7-8 | Completó pero le faltó algún detalle |
| **Suficiente** | 5-6 | Respuestas vagas o incompletas |
| **Insuficiente** | 0-4 | No completó la inspección |

### 2. Broker solitario (25%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| **Excelente** | 23-25 | Plantilla completa correctamente. Broker arrancó al primer intento. Validación con `kafka-broker-api-versions` exitosa |
| **Bueno** | 18-22 | Plantilla con 1-2 errores menores que pudo corregir |
| **Suficiente** | 13-17 | Necesitó ayuda significativa para llenar la plantilla |
| **Insuficiente** | 0-12 | El broker no arrancó |

### 3. Clúster de 3 brokers (30%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| **Excelente** | 27-30 | Replicó correctamente los 3 bloques. QUORUM_VOTERS correcto. CLUSTER_ID compartido. Los 3 brokers en quorum |
| **Bueno** | 21-26 | Configuración funcional con algún detalle subóptimo |
| **Suficiente** | 15-20 | Solo logró 2 brokers en quorum, o necesitó copy-paste de la solución |
| **Insuficiente** | 0-14 | Quorum no se forma |

### 4. Análisis del quorum (25%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| **Excelente** | 23-25 | Tabla completa. Mata al líder y observa re-elección. Conceptos claros |
| **Bueno** | 18-22 | Tabla completa pero análisis de re-elección incompleto |
| **Suficiente** | 13-17 | Solo describió el estado pero no hizo el experimento de fallo |
| **Insuficiente** | 0-12 | No completó el análisis |

### 5. Conclusiones (10%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| **Excelente** | 9-10 | 3-5 frases articuladas que demuestran entendimiento profundo |
| **Bueno** | 7-8 | Conclusiones correctas pero superficiales |
| **Suficiente** | 5-6 | Conclusiones vagas |
| **Insuficiente** | 0-4 | Sin conclusiones |

### 6. Desafío (10%, bono opcional)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| **Excelente** | 9-10 | Completó los 3 retos con análisis crítico |
| **Bueno** | 7-8 | Completó 2 de 3 retos |
| **Suficiente** | 5-6 | Solo intentó 1 reto |
| **Insuficiente** | 0-4 | No intentó el desafío |
