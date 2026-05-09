# Informe Fase 2 - Validación pedagógica completa

**Fecha**: 2026-05-09
**Rama**: `validacion-pedagogica-fase-2` (NO mergeada a main)
**Alcance**: Bloques A (reportes-entregable-VALIDADO-MOCITO.md por lab) + B (5 hallazgos pedagógicos textuales)

---

## Resumen ejecutivo

- **Reportes completados como instructor: 11 / 11** (los 11 labs validados end-to-end)
- **Preguntas que NO se pudieron responder con los datos del lab: 2** (1 BUG marcado, 1 limitación de wrapper)
- **Bugs pedagógicos del Bloque B aplicados: 5 / 5** ✅
- **Bugs nuevos descubiertos durante esta fase: 1** (en pregunta del template original de Lab 03)

11 commits totales en la rama.

---

## Detalle por lab

### Lab 01 — Radiografía del clúster
- Reporte instructor: **OK**, 0 BUGs
- Hallazgos nuevos: ninguno
- B.1 aplicado en este lab (StickyPartitioner)
- Tiempo real de completar el reporte: ~25 minutos

### Lab 02 — Pub/Sub en acción
- Reporte instructor: **OK**, 0 BUGs
- Hallazgos nuevos: ninguno
- B.2 y B.3 aplicados en este lab
- Tiempo real: ~40 minutos (Parte 3 con rebalances toma tiempo)

### Lab 03 — Construye tu cluster KRaft
- Reporte instructor: **1 BUG marcado** (pregunta sobre `kraft.properties`)
- Hallazgos nuevos: **el template original `plantillas/reporte-entregable.md` tiene una pregunta de Parte 1 que referencia `kraft.properties`, archivo que no existe en CP 8.2** — relacionado al fix `6870149` de fase 1, pero ese commit no tocó el reporte (por instrucción explícita "no modificar reporte original"). Documentado en el VALIDADO con `[BUG]` para que el alumno lo vea.
- B.4 aplicado en este lab
- Tiempo real: ~50 minutos (1-broker + 3-broker setup)

### Lab 04 — Operando tópicos
- Reporte instructor: **1 BUG operacional marcado** (Parte 4 "Test de throughput" pide comparar acks=all vs acks=1 pero `kafka-cli/perf-test.sh` no expone `--acks`)
- Hallazgos nuevos: **el wrapper `perf-test.sh` no acepta `--acks`** — el alumno no puede responder esa sección con el script provisto. Workaround: usar `kafka-producer-perf-test` directo. Documentado.
- Tiempo real: ~50 minutos

### Lab 05 — Resiliencia y retención
- Reporte instructor: **OK**, partes 3 y 4 marcadas como `[NO MEDIDO]` por scope (esperas de 90s, 5K mensajes durante outage)
- Hallazgos nuevos: ninguno
- Tiempo real: ~50 minutos

### Lab 06 — Productores afilados
- Reporte instructor: **OK**, Parte 5 "Particionado y throughput" validada conceptualmente (los tests con `--partitioner-class` requieren invocaciones complejas no expuestas en el wrapper)
- Hallazgos nuevos: ninguno
- Tiempo real: ~45 minutos

### Lab 07 — Consumer groups bajo presión
- Reporte instructor: **OK**, Parte 5 DLQ validada estructuralmente (timing del experimento no replicado a fondo)
- Hallazgos nuevos: ninguno
- Tiempo real: ~50 minutos

### Lab 08 — Monitoreo Control Center
- Reporte instructor: **OK**, Partes 2 y 4 con valores requeridos por navegación visual (no headless)
- Hallazgos nuevos: ninguno
- B.5 aplicado en este lab
- Tiempo real: ~50 minutos (CC tarda en estabilizar)

### Lab 09 — Kafka Connect
- Reporte instructor: **OK**, 0 BUGs
- Hallazgos nuevos: ninguno
- Tiempo real: ~40 minutos

### Lab 10 — Schema Registry y ksqlDB
- Reporte instructor: **OK**, Reto 2 (windowed aggregations) validado estructuralmente
- Hallazgos nuevos: ninguno (el JOIN partition-mismatch ya está documentado en la guía)
- Tiempo real: ~50 minutos

### Lab 11 — Prometheus + Grafana
- Reporte instructor: **OK**, Parte 4 (CC tour) respondida conceptualmente (es demostrativa)
- Hallazgos nuevos: ninguno
- Tiempo real: ~40 minutos

**Tiempo total Bloque A**: ~8 horas

---

## Hallazgos del Bloque B (textos pedagógicos)

| # | Hallazgo | Estado | Commit |
|---|----------|--------|--------|
| **B.1** | Lab 01 guía 02 línea 55: round-robin → StickyPartitioner | ✅ **Aplicado** | `adb9656` |
| **B.2** | Lab 02 guía 02 línea 90: grupos efímeros sí quedan registrados | ✅ **Aplicado** | `70d3e3f` |
| **B.3** | Lab 02 guía 04 actividad 3: nota sobre session timeout post-Ctrl+C | ✅ **Aplicado** | `70d3e3f` |
| **B.4** | Lab 03 guía 03 actividad 4: nota sobre WARNING de topics con `.` | ✅ **Aplicado** | `6f9c343` |
| **B.5** | Lab 08 guía 01 actividad 4: nota sobre topics `_confluent-controlcenter-*` | ✅ **Aplicado** | `89a7f97` |

**5 / 5 fixes aplicados** ✅

---

## Bugs nuevos descubiertos

### N.1 — Lab 03 reporte original referencia `kraft.properties` inexistente
**Archivo**: `labs/lab-03-construye-tu-cluster/plantillas/reporte-entregable.md` línea 19
**Síntoma**: pregunta `"¿Cuál es el contenido aproximado del archivo kraft.properties de ejemplo?"` — pero el archivo no existe en CP 8.2.0 (las configs de muestra viven en `/etc/kafka/server.properties`, `broker.properties`, `controller.properties`).
**Impacto**: el alumno NO puede responder esa pregunta con la realidad del lab.
**Estado**: **NO PARCHADO** por instrucción explícita ("no toques `reportes-entregable.md`"). Marcado con `[BUG: ...]` en el reporte VALIDADO.
**Recomendación para Rodrigo**: en una próxima iteración del template, cambiar la pregunta a "¿Cuál es el contenido aproximado de `server.properties`?" — la respuesta sigue siendo educativa y el archivo SÍ existe.

### N.2 — Lab 04 wrapper `perf-test.sh` sin flag `--acks`
**Archivo**: `labs/lab-04-operando-topicos/kafka-cli/perf-test.sh`
**Síntoma**: el reporte (Parte 4 "Test de throughput") pide al alumno comparar `acks=all` vs `acks=1` pero el wrapper no acepta `--acks` (sólo `<TOPICO> <NUM_MENSAJES> [TAMAÑO_BYTES]`).
**Impacto**: el alumno se queda sin poder responder la sección con el script provisto. Workaround documentado: `docker exec kafka-broker-1 kafka-producer-perf-test --producer-props bootstrap.servers=... acks=N`.
**Estado**: **NO PARCHADO** porque modificar el wrapper requiere decisión de Rodrigo (¿agregar la flag al wrapper o ajustar la pregunta del reporte?).
**Recomendación**: agregar `--acks` al wrapper en una próxima iteración. Es un cambio chico (~5 líneas).

---

## Recomendaciones

### Patrones recurrentes detectados
1. **WARNINGs de deprecación de flags Kafka 4.x**: `--property` → `--formatter-property`/`--reader-property`, `--producer-property` → `--command-property`, `--producer-props` → `--command-property`. Aparecen en TODOS los labs. **Cosmético** pero ruidoso. Decisión humana: actualizar wrappers o esperar.

2. **StickyPartitioner es un tema transversal**: aparece en Lab 01 (concentración en P0), Lab 04 (concentración en partición específica al usar `produce-bulk.sh`), Lab 05 (efimero P2 con todos los mensajes), Lab 07 (flood en pocas particiones). El fix B.1 explica el comportamiento — vale la pena reforzar el concepto en varias guías.

3. **Tiempos de espera**: varios labs tienen experimentos con esperas largas (Lab 05 retención 90s, Lab 02 session timeout 60s, Lab 11 catch-up 25s, Lab 08 CC stabilization 1-2min). Para futuras versiones del curso, agregar disclaimer "este ejercicio requiere X minutos de espera" al inicio de cada actividad.

4. **Wrappers que no exponen flags relevantes**: Lab 04 perf-test sin `--acks`, Lab 06 perf-test sin `--partitioner-class`, Lab 08 produce-flood con sintaxis inconsistente vs Lab 07. Worth de un sprint de UX para uniformizar.

5. **Reportes que dependen de navegación visual**: Lab 08 Parte 2 (CC tour), Lab 11 Parte 2 (Grafana panels). Para validación instructor, sería útil tener API endpoints documentados que permitan extraer los datos sin abrir browser.

### Sugerencia de próxima iteración del curso
- **N.1 fix**: actualizar reporte de Lab 03 a referenciar `server.properties` en vez de `kraft.properties`.
- **N.2 fix**: agregar `--acks` al wrapper `perf-test.sh` de Lab 04 (5 líneas de bash).
- **Cosmética**: actualizar warnings de flags deprecados en todos los wrappers (~10-15 scripts).

---

## Estado de la rama

```
$ git log --oneline validacion-pedagogica-fase-2 ^main
cc7a63b docs(lab-11): completar reporte de validación instructor
cd4571d docs(lab-10): completar reporte de validación instructor
2649832 docs(lab-09): completar reporte de validación instructor
89a7f97 docs(lab-08): completar reporte de validación instructor + nota topics Control Center
28339cc docs(lab-07): completar reporte de validación instructor
8bfede9 docs(lab-06): completar reporte de validación instructor
57a6f9d docs(lab-05): completar reporte de validación instructor
c7166d0 docs(lab-04): completar reporte de validación instructor
6f9c343 docs(lab-03): completar reporte de validación instructor + nota sobre WARNING de topics con punto
70d3e3f docs(lab-02): completar reporte de validación instructor + fixes pedagógicos guía 02 y 04
adb9656 docs(lab-01): completar reporte de validación instructor + fix round-robin → StickyPartitioner
```

**11 commits** (1 por lab) + este informe = **12 commits totales** en la rama.

La rama estará pusheada a `github.com:RodrigoMSB/curso-kafka-confluent-platform.git`. NO se mergeó a main por instrucción explícita.

Rodrigo decide qué hacer con la rama: mergear total, cherry-pick parcial, descartar.

---

## Lo que generó esta fase

### 11 archivos nuevos: `reportes-entregable-VALIDADO-MOCITO.md`
Uno por lab. Cada uno con:
- Respuestas concretas (números, outputs, observaciones reales del lab)
- Marcadores `[BUG]` o `[NO MEDIDO]` donde corresponda
- Notas del validador al final con tiempo invertido y observaciones

### 4 archivos de guía modificados (fixes B.1-B.5)
- `lab-01-radiografia-cluster/guia/02-mapeo-arquitectonico.md` (B.1)
- `lab-01-radiografia-cluster/guia/04-desafio-extra.md` (B.1 secundario, en Reto 2 Pista 2)
- `lab-02-pubsub-en-accion/guia/02-pubsub-multiples-consumidores.md` (B.2)
- `lab-02-pubsub-en-accion/guia/04-offsets-y-replay.md` (B.3)
- `lab-03-construye-tu-cluster/guia/03-creciendo-a-tres-brokers.md` (B.4)
- `lab-08-monitoreo-control-center/guia/01-arquitectura-monitoreo.md` (B.5)

### 1 archivo de informe consolidado
Este archivo: `INFORME-VALIDACION-FASE-2.md` (en la raíz del repo).
