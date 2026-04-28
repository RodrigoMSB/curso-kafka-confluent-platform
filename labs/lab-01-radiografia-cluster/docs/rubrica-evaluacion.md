# Rúbrica de evaluación - Lab 01: Radiografía de un clúster Kafka vivo

## Criterios de evaluación

| Criterio | Peso | Descripción |
|----------|------|-------------|
| Identificación de componentes | 20% | El alumno identifica correctamente todos los componentes del clúster y sus roles |
| Mapeo de particiones y líderes | 25% | El diagrama muestra correctamente la distribución de particiones, líderes e ISR |
| Experimento de tolerancia a fallos | 25% | Documentación completa del antes/durante/después con análisis correcto |
| Calidad de las conclusiones | 20% | Conclusiones fundamentadas en evidencia, con comprensión conceptual demostrada |
| Desafío extra | 10% (bonus) | Completitud y corrección de los retos adicionales |

---

## Detalle por criterio

### 1. Identificación de componentes (20%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| **Excelente** | 18-20 | Identifica los 5 componentes con imagen, puerto y función correcta. Explica la diferencia entre broker y controlador en KRaft. |
| **Bueno** | 14-17 | Identifica los 5 componentes con la mayoría de los datos correctos. Puede haber imprecisiones menores en las funciones. |
| **Suficiente** | 10-13 | Identifica al menos 4 componentes. Falta algún dato relevante (puertos, funciones). |
| **Insuficiente** | 0-9 | Identifica menos de 4 componentes o hay errores conceptuales graves (ej: confundir broker con consumidor). |

### 2. Mapeo de particiones y líderes (25%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| **Excelente** | 23-25 | Diagrama completo con líderes, réplicas ISR, productor, consumidor y Kafbat UI. Los datos coinciden con la salida real de los comandos. Usa la leyenda de colores correctamente. |
| **Bueno** | 18-22 | Diagrama tiene todos los elementos principales. Puede faltar algún detalle menor (ej: no todos los ISR marcados). |
| **Suficiente** | 13-17 | Diagrama muestra brokers y particiones pero falta la distribución de líderes/réplicas o el productor/consumidor. |
| **Insuficiente** | 0-12 | Diagrama incompleto o con errores graves. No distingue entre líderes y réplicas. |

### 3. Experimento de tolerancia a fallos (25%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| **Excelente** | 23-25 | Tablas completas de antes/después/recuperación. Identifica correctamente los cambios de liderazgo. Confirma que no se perdieron datos. Explica por qué Kafka siguió operando. |
| **Bueno** | 18-22 | Tablas mayormente completas. Identifica los cambios principales. Las explicaciones son correctas pero podrían ser más profundas. |
| **Suficiente** | 13-17 | Registra los estados pero el análisis es superficial. Puede confundir algunos conceptos (ej: creer que se perdieron datos). |
| **Insuficiente** | 0-12 | No ejecutó el experimento o los datos registrados son incorrectos/inventados. |

### 4. Calidad de las conclusiones (20%)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| **Excelente** | 18-20 | Conclusiones propias que demuestran comprensión profunda. Menciona réplicas, ISR, elección de líderes, y `min.insync.replicas` con contexto. Reflexiona sobre escenarios de fallo más graves. |
| **Bueno** | 14-17 | Conclusiones correctas que demuestran comprensión general. Puede faltar profundidad en algún aspecto. |
| **Suficiente** | 10-13 | Conclusiones genéricas ("Kafka es robusto") sin referencias específicas a lo observado. |
| **Insuficiente** | 0-9 | No hay conclusiones o son incorrectas. |

### 5. Desafío extra (10% bonus)

| Nivel | Puntos | Indicadores |
|-------|--------|-------------|
| **Completo** | 9-10 | Los 3 retos respondidos con comandos y explicaciones correctas. |
| **Parcial** | 5-8 | Al menos 2 retos completados correctamente. |
| **Intento** | 1-4 | 1 reto completado o intentos parciales en varios. |
| **No realizado** | 0 | No intentó el desafío. |

---

## Escala de calificación

| Rango | Calificación | Descripción |
|-------|-------------|-------------|
| 90-100+ | Sobresaliente | Comprensión excepcional |
| 80-89 | Notable | Comprensión sólida |
| 70-79 | Bueno | Comprensión adecuada con áreas de mejora |
| 60-69 | Suficiente | Comprensión básica, necesita refuerzo |
| < 60 | Insuficiente | No alcanza los objetivos mínimos |

---

## Entregables esperados

- [ ] Reporte completado (`plantillas/reporte-entregable.md`)
- [ ] Diagrama del clúster (draw.io o foto)
- [ ] Tablas de tolerancia a fallos con datos reales
- [ ] Conclusiones escritas

---

*Rúbrica de evaluación - Lab 01*
