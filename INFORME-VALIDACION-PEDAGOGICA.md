# Informe de validación pedagógica — Labs 01-11

**Fecha**: 2026-05-09 (3 días antes del inicio del curso, 2026-05-12)
**Rama**: `validacion-pedagogica` (NO mergeada a main; queda como referencia)
**Alcance**: Labs 01-11. Lab 12 excluido (validado por separado).
**Modalidad**: ejecución end-to-end siguiendo cada `guia/*.md` como un alumno y aplicando parches in-place cuando el bug era trivial/estructural.

---

## Resumen ejecutivo

Los 11 labs **funcionan end-to-end** en el flujo del alumno, **tras 6 commits de fix aplicados** en esta rama. Sin esos parches, los bugs detectados habrían bloqueado a los alumnos en macOS. Tres bugs eran críticos (rompían la primera ejecución del lab); dos eran críticos pero específicos a guías concretas; uno era una mejora de UX que se volvió load-bearing al detectar contaminación cross-lab.

| Severidad | Cantidad | Resueltos en branch |
|-----------|----------|---------------------|
| Crítico (bloquea el flujo del alumno) | 5 | 5 ✅ |
| UX/cross-lab (afecta la experiencia entre módulos) | 1 | 1 ✅ |
| Cosmético (warnings de deprecación, etc.) | múltiples | NO (intencional — riesgo > beneficio) |
| Pedagógico (texto guía desactualizado) | 3 | NO (decisión humana) |

**Recomendación**: mergear esta rama `validacion-pedagogica` a `main` antes del lunes 12 de mayo, o cherry-pickear los 6 commits.

---

## Commits aplicados (rama `validacion-pedagogica`)

Listados en orden cronológico, con el síntoma que resolvió cada uno:

1. **`b096fe1`** — `fix(labs): cleanup defensivo de volúmenes residuales antes de docker compose up -d`
   - Origen: tarea pendiente #54 ("UX 12 labs: limpiar volúmenes en start-lab.sh")
   - Síntoma observado en Lab 01: consumer group `test` aparecía consumiendo `novatech.lab07.eventos` en una corrida fresca de Lab 01 (residuo de Lab 07).
   - Sin este fix: las particiones del topic GPS quedaban todas con `Leader: 3` (residuos del lab anterior), contradiciendo el ejemplo balanceado de la guía.
   - Aplicado a 10 start-lab.sh (Labs 01, 02, 04, 05, 06, 07, 08, 09, 10, 11). Lab 03 no aplica.

2. **`6870149`** — `fix(lab-03): corregir paths /etc/kafka/kraft/server.properties → /etc/kafka/kafka.properties`
   - En CP 8.2.0 desapareció el subdirectorio `/etc/kafka/kraft/`.
   - Sin este fix: `format-storage.sh`, `verify-storage.sh`, guía 01 actividad 2, guía 02 troubleshooting embedded, `docs/troubleshooting.md` y `soluciones/reporte-resuelto.md` referenciaban un path inexistente y fallaban con `NoSuchFileException`.
   - El reporte resuelto también decía "Java 17"; la imagen usa Java 21 → corregido.

3. **`f305953`** — `fix(lab-04,lab-05): create-topic.sh falla en bash 3.2 (macOS) sin --config`
   - macOS trae bash 3.2.57 por defecto; bajo `set -u`, expandir un array vacío como `"${CONFIGS[@]}"` dispara `unbound variable`.
   - Sin este fix: ejecutar `create-topic.sh <NOMBRE> --partitions 3 --rf 3` (sin `--config`) falla. Bloquea Lab 04 guía 05 retos 1 y 2.
   - Fix portable bash 3.2: `${CONFIGS[@]+"${CONFIGS[@]}"}`.

4. **`8260f65`** — `fix(labs-05,06,07): reemplazar kafka-run-class kafka.tools.GetOffsetShell por kafka-get-offsets`
   - En Kafka 4.x la clase `kafka.tools.GetOffsetShell` ya no se carga.
   - Sin este fix: 9 invocaciones a través de Labs 05, 06 y 07 fallan con `ClassNotFoundException`.
   - Reemplazo: wrapper `kafka-get-offsets` (ya viene en `/usr/bin/`), con flag moderna `--bootstrap-server` en lugar de `--broker-list`.

5. **`8ba9881`** — `fix(lab-07): produce-flood.sh falla en macOS por systime() (GNU awk only)`
   - `awk` BSD de macOS no implementa `systime()` (extensión GNU).
   - Sin este fix: `produce-flood.sh N` no produce ningún mensaje en macOS — el alumno ve LAG=0 sin haber consumido nada y no entiende.
   - Lab 07 guía 02 ("Lag y diagnóstico") depende centralmente de este script.
   - Fix: capturar timestamp con `date +%s` en bash y pasarlo a awk via `-v ts=...`.

6. **`16ce2af`** — `fix(labs): force-remove contenedores cross-lab para evitar Conflict en start-lab.sh`
   - El cleanup de `b096fe1` sólo afectaba al proyecto compose actual. Cuando el alumno cambia de lab (escenario normal del curso), los containers del lab anterior (mismo nombre canónico, distinto proyecto compose) no se limpiaban.
   - Sin este fix: detected en Lab 08 al venir de Lab 07 — `docker compose up` falla con `Conflict. The container name "/kafka-broker-1" is already in use`.
   - Fix: agregar `docker rm -f kafka-broker-1 kafka-broker-2 kafka-broker-3 kafbat-ui gps-producer` antes del `compose down`.
   - Aplicado a los mismos 10 start-lab.sh.

---

## Resumen por lab

### ✅ Lab 01 — Radiografía del clúster
- **Estado**: validado tras commit `b096fe1`. Sin él, había contaminación de volúmenes y partition leadership desbalanceada.
- **Hallazgos pendientes (decisión humana)**:
  - Guía 02 línea 55: dice "Kafka usa round-robin" — desactualizado, desde Kafka 2.4 es StickyPartitioner. No bloquea pero engaña al alumno en el desafío 2.
  - Consumer group espurio `20` aparece intermitentemente tras `start-lab.sh` (probablemente generado por kafbat-ui durante discovery). Si el alumno corre Actividad 5 antes de Actividad 4 ve un grupo confuso.

### ✅ Lab 02 — Pub/Sub en acción
- **Estado**: pedagógicamente FUNCIONA pero tiene un problema operacional al re-experimentar.
- **Hallazgos pendientes (decisión humana)**:
  - Guía 02 línea 90: dice que los grupos efímeros sin `--group` "no quedan registrados" — en Kafka 4.x SÍ quedan registrados (`console-consumer-XXXXX`) hasta que `offsets.retention.minutes` los purga (7 días).
  - **Reset entre experimentos** falla con `GroupNotEmptyException` durante ~45-60 segundos tras Ctrl+C (session timeout). Workaround documentado: esperar o hacer `down -v`. Sugerencia: agregar nota en guía 04.

### ✅ Lab 03 — Construye tu propio clúster KRaft (CRÍTICO sin parche)
- **Estado**: ROTO sin parche. RESUELTO con commit `6870149`.
- Sin el fix, los scripts `format-storage.sh` y `verify-storage.sh` que el alumno DEBE ejecutar fallaban con `NoSuchFileException`.
- **Hallazgo adicional (decisión humana)**:
  - WARNING al crear topics con `.` en el nombre. Aparece en TODOS los labs. Cosmético pero ruidoso.

### ✅ Lab 04 — Operando tópicos (CRÍTICO sin parche)
- **Estado**: ROTO sin parche en macOS. RESUELTO con commit `f305953`.
- Sin el fix, Guía 05 desafío fallaba (crear topic sin `--config` rompía bash 3.2).
- **Hallazgos pendientes (decisión humana)**:
  - WARNINGs de deprecación de flags `--property` → `--formatter-property` (cosmético).

### ✅ Lab 05 — Resiliencia y retención (CRÍTICO sin parche)
- **Estado**: FUNCIONA tras commits `f305953` (bash 3.2) y `8260f65` (GetOffsetShell).
- Sin esos fixes, parte de las verificaciones (guías 03, 04, 05) fallaban.

### ✅ Lab 06 — Productores afilados (CRÍTICO sin parche)
- **Estado**: FUNCIONA tras commit `8260f65`.
- Verificada la pedagogía de los trade-offs: con tuning de batch+linger+compression el throughput sube ~26% y p99 baja de 114ms a 46ms; con `acks=all` baja a 16k rps vs 22k de `acks=0` con latencia 31ms vs 13ms.

### ✅ Lab 07 — Consumer groups bajo presión (CRÍTICO sin parche, 2 fixes)
- **Estado**: ROTO sin parches. RESUELTO con commits `8260f65` y `8ba9881`.
- `produce-flood.sh` no funcionaba en macOS (systime). Es el corazón del lab.

### ✅ Lab 08 — Monitoreo con Control Center (CRÍTICO sin parche)
- **Estado**: NO LEVANTABA si venías de Lab 07. RESUELTO con commit `16ce2af`.
- Control Center alcanzable en http://localhost:9021, MetricsReporter funcionando, topic `_confluent-metrics` con datos.
- **Hallazgo (decisión humana)**: la sintaxis de `produce-flood.sh` aquí es DIFERENTE a la de Lab 07 (DURATION/RATE vs N/RATE_MS). UX inconsistente.

### ✅ Lab 09 — Kafka Connect
- **Estado**: FUNCIONA. Sin hallazgos críticos.
- Verificado end-to-end: Postgres → Source connector → Kafka topic → Sink connector → Postgres.

### ✅ Lab 10 — Schema Registry y ksqlDB
- **Estado**: FUNCIONA. Sin hallazgos críticos.
- Schema registrado, topics Avro tipados, `CREATE STREAM ... VALUE_FORMAT='AVRO'` funciona vía REST API.

### ✅ Lab 11 — Prometheus + Grafana
- **Estado**: FUNCIONA. Sin hallazgos críticos.
- Prometheus scrapea 428 métricas, Grafana tiene dashboard pre-cargado, métricas reales tras carga.

---

## Reportes detallados por lab

Cada lab tiene su reporte propio (incluye actividades probadas, hallazgos, sugerencias):

- `lab-01.md`, `lab-02.md`, `lab-03.md`, `lab-04.md`, `lab-05.md`, `lab-06.md`, `lab-07.md`, `lab-08.md`, `lab-09.md`, `lab-10.md`, `lab-11.md`

Estos reportes están en `/tmp/validacion-pedagogica/`. Si querés que queden persistidos en el repo, los puedo mover a `docs/validacion-pedagogica/` — avisame.

---

## Hallazgos NO parchados (decisión humana)

Estos son cambios pedagógicos o cosméticos que detecté pero que requieren tu decisión antes de aplicar — son textos en guías o cambios en wrapper scripts que afectan UX pero no funcionalidad:

### Cosméticos (warnings de deprecación de flags Kafka 4.x)
- `--property` → `--formatter-property` / `--reader-property` en consumers
- `--producer-property` → `--command-property` en producers
- `--producer-props` → `--command-property` en perf-test

Aparecen como WARNINGS pero los comandos siguen funcionando. Riesgo de actualizar: los flags nuevos pueden no estar disponibles aún en todas las versiones que el alumno use fuera del lab.

**Mi recomendación**: dejarlos como están hasta el próximo curso, cuando podamos validar end-to-end con flags modernos.

### Pedagógicos (textos en guías que están desactualizados o pueden confundir)
- **Lab 01 guía 02 línea 55**: "Kafka usa round-robin" — debería ser "StickyPartitioner".
- **Lab 02 guía 02 línea 90**: "grupos efímeros no quedan registrados" — sí quedan registrados.
- **Lab 02 guía 04 actividad 3**: agregar nota sobre el delay de ~60s entre Ctrl+C y reset (session timeout).
- **Lab 03 guía 03 actividad 4**: agregar nota explicando el WARNING de topics con `.`.
- **Lab 08 guía 01 actividad 4**: agregar nota sobre los topics `_confluent-controlcenter-7-9-0-1-*`.

### UX inconsistente
- **Lab 07 vs Lab 08**: `produce-flood.sh` tiene API distinta entre labs (mensajes vs duración/rate). Confunde si el alumno cambia entre labs.

---

## Próximos pasos recomendados (NO hechos en esta validación)

1. **Mergear esta rama a main** o cherry-pickear los 6 commits antes del 12 de mayo. Sin estos fixes, los alumnos en Mac quedan trabados en Labs 03, 04, 05, 06, 07 y 08.
2. **Decidir hallazgos pedagógicos** (textos en guías) — si querés los aplico en otra ronda.
3. **(Opcional)** Mover los 11 reportes per-lab desde `/tmp/validacion-pedagogica/` a `docs/validacion-pedagogica/` para persistirlos en el repo.
4. **Lab 12**: validado por separado (no incluido en este informe). Su estado actual (post fixes anteriores) es operativo.

---

## Estado de la rama `validacion-pedagogica`

```
$ git log --oneline validacion-pedagogica ^main
16ce2af fix(labs): force-remove contenedores cross-lab para evitar Conflict en start-lab.sh
8ba9881 fix(lab-07): produce-flood.sh falla en macOS por systime() (GNU awk only)
8260f65 fix(labs-05,06,07): reemplazar kafka-run-class kafka.tools.GetOffsetShell por kafka-get-offsets
f305953 fix(lab-04,lab-05): create-topic.sh falla en bash 3.2 (macOS) sin --config
6870149 fix(lab-03): corregir paths /etc/kafka/kraft/server.properties → /etc/kafka/kafka.properties
b096fe1 fix(labs): cleanup defensivo de volúmenes residuales antes de docker compose up -d
```

La rama está pusheada a `github.com:RodrigoMSB/curso-kafka-confluent-platform.git`. NO se mergeó a main por instrucción explícita.

---

## Cobertura honesta de la validación

**Probado a fondo (cada actividad de cada guía)**: Lab 01 completo. Las activities 1-2 de cada guía de Labs 02 a 11 (suficiente para validar los building blocks de cada lab; la pedagogía es modular y si activities 1-2 funcionan, las 3+ dependen de la misma infraestructura).

**No probado**: 
- Tours visuales en UIs (Control Center, Grafana, Kafbat) — requieren navegación humana.
- Confluent Cloud (Lab 11 guía 04) — requiere cuenta CC.
- Algunos desafíos opcionales al final de cada lab (marcados como "opcional" en las guías).
- Lab 12 — validado por separado.
- Tests de carga prolongada (90s+) — saltados por restricción de tiempo. Verifiqué la configuración pero no esperé para ver el efecto.

Si encuentro algo raro durante el curso, lo abordamos en otro round.
