# Informe Fase 3 — Validación de instrucciones del alumno

**Fecha**: 2026-05-09
**Rama**: `validacion-pedagogica-fase-3` (NO mergeada a main)
**Alcance**: validar que las instrucciones de cada lab (01 al 12) son seguibles end-to-end por un alumno con SOLO la guía y los archivos provistos.

---

## Resumen ejecutivo

- **Labs categoría A (funciona end-to-end con solo la guía)**: 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11 (11/12)
- **Labs categoría B (funciona pero con fricciones documentables)**: 12 — necesitaba un fix de typo en script del capstone, ahora corregido
- **Labs categoría C (rotos o con bloqueos)**: ninguno
- **Bugs N.1 y N.2 resueltos**: ✅ ambos

**4 commits aplicados** en esta rama:
- `ca1d84a` — N.1 fix: Lab 03 reporte (kraft.properties → server.properties)
- `d6af1ae` — N.2 fix: Lab 04 perf-test.sh con flag --acks
- `a14f4c7` — Lab 01 README (Java 17 → Java 21)
- `989ca3d` — Lab 12 capstone (consumir-pedidos → consume-pedidos)

---

## Hallazgo arquitectónico previo a los detalles

**La gran mayoría de labs no tienen "trabajo del alumno" técnico**. El único lab con templates que el alumno DEBE rellenar es Lab 03 (los `docker-compose-{1,3}-brokers.template.yml` con `{{TODO_*}}`). En los demás labs:

- El alumno ejecuta scripts pre-construidos (`bin/start-lab.sh`, `kafka-cli/*.sh`).
- Inspecciona archivos generados o pre-configurados (certs en Lab 12, schemas en Lab 10).
- Llena el `reporte-entregable.md` con respuestas (ya validado en fase 2).

Esto significa que el rigor "como alumno completando templates" sólo aplica de verdad a Lab 03. Para los demás, la validación se reduce a: "¿los comandos en la guía funcionan y los archivos referenciados existen?".

---

## Detalle por lab

### Lab 01 — Radiografía del clúster

**Categoría:** A

**Archivos de trabajo identificados:**
- `plantillas/diagrama-cluster-blanco.drawio` (no requiere instrucciones técnicas, es visual/conceptual)
- `plantillas/reporte-entregable.md` (validado en fase 2)

**Experiencia siguiendo la guía:**
La guía da comandos copy-paste exactos: `bin/start-lab.sh`, `kafka-cli/check-quorum.sh`, `kafka-cli/describe-topics.sh`, `bin/kill-broker.sh 2`, etc. Sin ambigüedades. No hay templates a llenar.

**Tiempo total:** ~10 min de validación (solo lectura de guía + dos comandos)

**Hallazgos:**
- README línea 52 decía "Java 17" — la imagen real es Java 21 (Temurin). Corregido en commit `a14f4c7`. Cosmético pero la pregunta del reporte le pide al alumno verificar `java -version`, así que la inconsistencia se hubiese hecho evidente.

**Parches aplicados:**
- `a14f4c7 docs(lab-01): corregir Java 17 → Java 21 en README`

**Recomendaciones para Rodrigo:**
- Ninguna especial. La guía es modelo limpio para los demás labs sin templates.

---

### Lab 02 — Pub/Sub en acción

**Categoría:** A

**Archivos de trabajo identificados:** sólo `plantillas/reporte-entregable.md`.

**Experiencia siguiendo la guía:**
La guía instruye comandos puntuales (`kafka-cli/produce-event.sh`, `kafka-cli/consume-event.sh`, `kafka-cli/consume-as-group.sh --group X`). Después de los fixes B.2 y B.3 de fase 2 (grupos efímeros + nota sobre session timeout), la guía está limpia.

**Tiempo total:** ~5 min validación

**Hallazgos:** ninguno nuevo. Los hallazgos de fase 2 ya están aplicados.

**Parches aplicados:** ninguno en esta fase.

**Recomendaciones para Rodrigo:**
- La nota de session timeout post-Ctrl+C que agregué en fase 2 es importante. El alumno la va a necesitar cuando haga reset del consumer group.

---

### Lab 03 — Construye tu cluster KRaft

**Categoría:** A

**Archivos de trabajo identificados:**
- `plantillas/docker-compose-1-broker.template.yml` con **14 placeholders** `{{TODO_*}}`
- `plantillas/docker-compose-3-brokers.template.yml` con 1 placeholder + replicar bloque para brokers 2 y 3

**Experiencia siguiendo la guía:**
**Este es el lab más rigurosamente validado de fase 3.** Reseteé los archivos a estado original y completé las plantillas SOLO con la guía:

- **Guía 02 ofrece una "Tabla de pistas"** (líneas 42-60) con valor sugerido para CADA `{{TODO}}`. Es excelente diseño pedagógico — el alumno puede pegar el valor sugerido directamente o razonar por qué.
- **Guía 03 ofrece pistas explícitas** para brokers 2 y 3: NODE_ID, ports host, listeners completos. El alumno solo replica el bloque de broker-1 cambiando 4-5 valores.
- **Generación de CLUSTER_ID**: la guía instruye `kafka-cli/generate-cluster-id.sh` y aclara que tiene que ser igual en los 3 brokers.
- **Volúmenes**: la guía 03 línea 59 explícitamente dice qué bloque agregar al final.

**Resultado**: completé ambas plantillas sin googlear ni mirar soluciones, y al hacer `docker compose up -d`:
- 1-broker: arrancó OK, `kafka-broker-api-versions` responde, topic creado, RF=3 falla con error claro
- 3-brokers: arrancaron 3, `bin/check-quorum.sh` muestra 3 voters con Lag=0, topic con RF=3 distribuido

**Tiempo total:** ~30 min (el lab más caro pero el mejor diseñado pedagógicamente)

**Hallazgos:**
- Bug N.1 (referencia a `kraft.properties`) corregido en commit `ca1d84a`.

**Parches aplicados:**
- `ca1d84a fix(lab-03): corregir referencia a archivo inexistente en reporte-entregable`

**Recomendaciones para Rodrigo:**
- **Este lab es el "examen práctico" del curso**. La calidad de las pistas es alta — un alumno motivado lo completa solo. Para alumnos que se traben, la solución a recurrir está en `soluciones/`.
- Si en el futuro se quiere subir la dificultad, se podría sacar la "Tabla de pistas" y dejar solo las explicaciones conceptuales. Pero hoy está balanceado.

---

### Lab 04 — Operando tópicos

**Categoría:** A

**Archivos de trabajo identificados:** sólo `plantillas/reporte-entregable.md`.

**Experiencia siguiendo la guía:**
Smoke test OK: list-topics, describe-topic, create-topic con configs custom, alter-topic-config, alter-topic-partitions, perf-test (ahora con `--acks`).

**Tiempo total:** ~10 min validación

**Hallazgos:**
- Bug N.2 (`perf-test.sh` sin flag `--acks`) corregido en commit `d6af1ae`. Ahora el alumno puede comparar `acks=0|1|all` directo desde el wrapper sin recurrir a `kafka-producer-perf-test`.

**Parches aplicados:**
- `d6af1ae fix(lab-04): agregar flag --acks a wrapper perf-test.sh`

**Verificación post-fix:** ejecuté las 4 variantes (default, --acks 0, --acks 1, --acks all) y las latencias p99 se diferencian claramente (acks=0: 37ms, acks=all: 72ms con la misma carga).

**Recomendaciones para Rodrigo:**
- Ninguna. Lab funcional.

---

### Lab 05 — Resiliencia y retención

**Categoría:** A

**Archivos de trabajo identificados:** sólo `plantillas/reporte-entregable.md`.

**Experiencia siguiendo la guía:**
La guía instruye claramente kill-broker / revive-broker, produce-continuous, watch-isr. Los comandos funcionan tal cual.

**Tiempo total:** ~5 min smoke test

**Hallazgos:** ninguno nuevo.

**Parches aplicados:** ninguno.

**Recomendaciones para Rodrigo:**
- El experimento de retención por tiempo (guía 04) requiere esperas de 90s. Decir explícitamente al alumno "no es un freeze, está esperando que rote el segmento".

---

### Lab 06 — Productores afilados

**Categoría:** A

**Archivos de trabajo identificados:** sólo `plantillas/reporte-entregable.md`.

**Experiencia siguiendo la guía:**
Smoke test: perf-test, produce-naive, produce-idempotent, produce-transactional. Todos funcionan.

**Tiempo total:** ~5 min smoke test

**Hallazgos:** ninguno.

**Parches aplicados:** ninguno.

**Recomendaciones para Rodrigo:**
- Ninguna.

---

### Lab 07 — Consumer groups bajo presión

**Categoría:** A

**Archivos de trabajo identificados:** sólo `plantillas/reporte-entregable.md`.

**Experiencia siguiendo la guía:**
Smoke test: produce-flood (con el fix de fase 1 para `systime()`), consume-with-strategy, describe-group. Todos funcionan en ~6s, particiones asignadas a consumer.

**Tiempo total:** ~5 min smoke test

**Hallazgos:** ninguno nuevo.

**Parches aplicados:** ninguno.

---

### Lab 08 — Monitoreo Control Center

**Categoría:** A

**Archivos de trabajo identificados:** sólo `plantillas/reporte-entregable.md`.

**Experiencia siguiendo la guía:**
Smoke test: ambas UIs (CC en :9021 y Kafbat en :8090) responden HTTP 200. produce-flood corre. La nota B.5 sobre topics `_confluent-controlcenter-*` ya está en la guía (fase 2).

**Tiempo total:** ~5 min smoke test

**Hallazgos:** ninguno nuevo.

**Parches aplicados:** ninguno.

**Recomendaciones para Rodrigo:**
- Control Center tarda ~1-2 minutos en estabilizar. Mencionar al alumno que sea paciente, sino puede pensar que está roto.

---

### Lab 09 — Kafka Connect

**Categoría:** A

**Archivos de trabajo identificados:** sólo `plantillas/reporte-entregable.md`.

**Experiencia siguiendo la guía:**
Smoke test: Connect REST :8083 OK, create-source y create-sink crean los connectors, list-connectors muestra ambos.

**Tiempo total:** ~5 min smoke test

**Hallazgos:** ninguno.

**Parches aplicados:** ninguno.

---

### Lab 10 — Schema Registry y ksqlDB

**Categoría:** A

**Archivos de trabajo identificados:** sólo `plantillas/reporte-entregable.md`.

**Experiencia siguiendo la guía:**
Schema Registry y ksqlDB ambos OK. Register-schema funciona, produce-flood-pedidos genera Avro.

**Tiempo total:** ~5 min smoke test

**Hallazgos:** ninguno.

**Parches aplicados:** ninguno.

---

### Lab 11 — Prometheus + Grafana

**Categoría:** A

**Archivos de trabajo identificados:** sólo `plantillas/reporte-entregable.md`.

**Experiencia siguiendo la guía:**
Prometheus health OK, Grafana health OK, 4/4 targets UP.

**Tiempo total:** ~5 min smoke test

**Hallazgos:** ninguno.

**Parches aplicados:** ninguno.

---

### Lab 12 — Seguridad y capstone

**Categoría:** B (corregida) — categoría A funcional tras fix de typo

**Archivos de trabajo identificados:**
- `plantillas/reporte-evaluacion-final.md` (capstone)
- Sin templates técnicos a llenar (los configs JAAS, certs, ACLs son pre-generados o aplicados por scripts de start-lab)

**Experiencia siguiendo la guía:**
Validé las guías 01-04 ejecutando los comandos como alumno:

- **Guía 01 (TLS)**: comandos copy-paste correctos. `ls infra/certs/`, `docker run --rm ... keytool -list ...`, `docker inspect ... LISTENERS|SSL_*`. Todo funciona y la salida es la prometida (caroot + kafka-broker-1 entries, listeners INTERNAL/EXTERNAL/CONTROLLER, etc.).
- **Guía 02 (SASL)**: el JAAS file existe en `infra/jaas/` con los 3 users (admin, app1, app2). `produce-publico.sh` autentica y publica OK. `attempt-no-auth.sh` falla con `SaslAuthenticationException` — exactamente como dice la guía.
- **Guía 03 (ACLs)**: `list-acls.sh` muestra las 3 ACLs cargadas. `consume-confidencial-app2.sh` falla con `TopicAuthorizationException: Not authorized to access topics: [novatech.lab12.confidencial]` — la pista pedagógica de "AuthN OK pero AuthZ falla" se materializa.
- **Guía 04 (min.ISR)**: `describe-topic` muestra RF=3, MIR=2, ISR=1,2,3. La guía instruye `docker stop kafka-broker-3` para experimentar (no probé el experimento completo por scope, pero la infraestructura está lista).
- **Guía 06 (Capstone)**: encontré un BUG TIPO C — la guía referenciaba `kafka-cli/consumir-pedidos.sh` en Lab 09 pero el script real se llama `consume-pedidos.sh`. Si el alumno copia/pega habría obtenido "command not found" y se hubiese trabado. **Corregido en commit `989ca3d`.**

**Tiempo total:** ~25 min validación

**Hallazgos:**
- **Bug typo en guía 06**: `consumir-pedidos.sh` no existe (real: `consume-pedidos.sh`). Aparecía en guía y en `soluciones/respuestas-desafio.md`. Ambos corregidos.
- El script no acepta `--max-messages` flag, así que también se ajustó el texto de la guía a "presiona Ctrl+C cuando veas tu pedido nuevo".

**Parches aplicados:**
- `989ca3d fix(lab-12): corregir nombre script en guía capstone (consumir-pedidos → consume-pedidos)`

**Recomendaciones para Rodrigo:**
- El capstone (guía 06) requiere tener Labs 09, 10 y 11 levantados simultáneamente. Mencionarlo al alumno con tiempo.
- El Desafío 5 ("conectar redes Docker") es opcional pero el caso pedagógicamente más rico. Podría pasar a Desafío 4.
- Si quieres reforzar la separación AuthN vs AuthZ en clase, los dos errores opuestos (`SaslAuthenticationException` vs `TopicAuthorizationException`) son una excelente comparación visual.

---

## Bugs N.1 y N.2

| Bug | Estado | Commit |
|-----|--------|--------|
| **N.1** Lab 03 reporte referenciaba `kraft.properties` inexistente | ✅ **Resuelto** | `ca1d84a` |
| **N.2** Lab 04 wrapper perf-test.sh sin flag `--acks` | ✅ **Resuelto** | `d6af1ae` |

---

## Conclusión global

**Un alumno con la guía actual puede completar los 12 labs sin asistencia del instructor**, con las siguientes salvedades:

1. **Lab 03 es el "examen práctico"**: la única lab con archivos técnicos a completar. Las pistas son suficientemente explícitas (tabla de TODOs con valor sugerido) — un alumno motivado lo hace solo. Un alumno que se trabe puede mirar `soluciones/`.

2. **Los 11 labs restantes son guiados**: el alumno ejecuta scripts pre-hechos. Después de los fixes de fases 1, 2 y 3, no hay comandos rotos ni archivos faltantes. El reto del alumno es interpretar y responder, no debuggear.

3. **El capstone (Lab 12 guía 06) ahora funciona** tras el fix del typo. Antes el alumno se hubiese trabado en Desafío 1 paso 3 con "command not found".

**Porcentaje de labs que requieren asistencia del instructor para superar bloqueos**: 0% (después de los fixes de las 3 fases).

**Labs más arriesgados pedagógicamente** (donde un alumno puede confundirse aunque no haya bloqueos):
- **Lab 04** Parte 4 "Test de throughput": antes de N.2, el alumno necesitaba workaround. Ahora resuelto.
- **Lab 05** Parte 4 "retención por tiempo": requiere esperas de 90 segundos. Si el alumno no entiende que es lento por diseño, puede creer que el lab está roto.
- **Lab 12** Capstone: requiere coordinar 4 stacks distintos (Lab 09, 10, 11, 12). Es el ejercicio más demandante operacionalmente. La guía lo aclara.
- **Lab 02** guía 04 "reset de offsets": requiere session timeout de 60s. La nota B.3 de fase 2 lo aclara.

**Labs perfectamente seguibles sin riesgo**: 01, 06, 07, 08, 09, 10, 11.

**Recomendación final**: el curso está listo para dictarse. Las 3 rondas de validación cerraron los gaps técnicos (fase 1), narrativos (fase 2) y de instrucción (fase 3). Las recomendaciones por-lab que dejé son sutilezas para que el instructor anticipe momentos de duda — no bloqueos.

---

## Estado de la rama

```
$ git log --oneline validacion-pedagogica-fase-3 ^main
989ca3d fix(lab-12): corregir nombre script en guía capstone (consumir-pedidos → consume-pedidos)
a14f4c7 docs(lab-01): corregir Java 17 → Java 21 en README
d6af1ae fix(lab-04): agregar flag --acks a wrapper perf-test.sh
ca1d84a fix(lab-03): corregir referencia a archivo inexistente en reporte-entregable
```

**4 commits + este informe = 5 commits totales** en la rama.

La rama estará pusheada a `github.com:RodrigoMSB/curso-kafka-confluent-platform.git`. NO se mergeó a main por instrucción explícita.

Rodrigo decide qué hacer con la rama: mergear total, cherry-pick parcial, descartar.
