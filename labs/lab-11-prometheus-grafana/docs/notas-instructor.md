# Notas para el Instructor - Lab 11

## Distribución de tiempo sugerida

| Parte | Tiempo |
|-------|--------|
| Setup (imágenes pre-descargadas) | 10 min |
| Parte 1: Arquitectura | 15 min |
| Parte 2: Tour Grafana | 25 min |
| Parte 3: Métricas bajo carga | 25 min |
| Parte 4: Tour Confluent Cloud | 30 min |
| Parte 5: Comparativa final | 10 min |
| Discusión | 5 min |
| **Total** | **~120 min** |

---

## Antes de la clase

Pre-descargar imágenes en TODAS las máquinas:

```bash
docker pull confluentinc/cp-kafka:8.2.0
docker pull prom/prometheus:v3.0.1
docker pull grafana/grafana:11.4.0
docker pull ghcr.io/kafbat/kafka-ui:latest
```

El JMX Exporter JAR (`jmx_prometheus_javaagent-1.0.1.jar`) ya viene incluido
en `infra/jmx-exporter/`. Si por alguna razón no está, descargarlo manualmente:

```bash
cd infra/jmx-exporter
curl -L -o jmx_prometheus_javaagent.jar \
  https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/1.0.1/jmx_prometheus_javaagent-1.0.1.jar
```

---

## Honestidad pedagógica obligatoria

Documentar EXPLÍCITAMENTE en clase:

1. **Decisión de tour vs práctico para Confluent Cloud**: el temario solicita
   que el alumno cree una cuenta gratuita en Confluent Cloud y despliegue un
   clúster. Sin embargo, Confluent Cloud requiere agregar tarjeta de crédito
   personal (incluso para el free tier). En cursos corporativos, esta
   exigencia genera fricciones legítimas con los alumnos.

   **Decisión**: la parte de Confluent Cloud se entrega como **tour visual
   guiado por el instructor**, usando capturas reales de su propia cuenta.
   El alumno observa, anota, y compara. Para quienes deseen replicar
   personalmente después del curso, la guía 04 incluye URLs y pasos.

2. **Sobre versiones**: Prometheus v3.0.1 y Grafana 11.4.0 son las versiones
   open-source más recientes a la fecha del curso. JMX Exporter 1.0.1 es la
   versión estable del Java agent.

3. **Limitación reconocida del dashboard de la comunidad**: el dashboard ID
   11962 puede tener queries que requieran ajustes según la versión de Kafka.
   Si una métrica aparece como "No data", el alumno aprende que **los
   dashboards de la comunidad son punto de partida, no copia-pega**.

4. **Stack open-source vs enterprise**: Prometheus + Grafana es lo que el
   90% de las empresas con Kubernetes ya tienen. Reusar esa infra para
   monitorear Kafka es lo más económico. CC y Cloud son negocios distintos.

---

## Puntos a enfatizar

### Parte 1 (arquitectura)
- **JMX Exporter es un agente Java**: no es un servicio aparte, vive en el
  proceso del broker. Por eso la métrica está siempre disponible aunque la
  red esté congestionada.
- **Pull vs push**: Prometheus hace pull (scrape). CC Next-Gen hacía push
  (OTLP). Cada arquitectura tiene tradeoffs.

### Parte 2 (tour Grafana)
- **Las 4 métricas críticas**: si no recuerdas nada más del lab, recuerda
  estas 4 (Bytes In/Out, Request Rate, URP, Active Controllers).
- **Active Controllers**: insistir que SIEMPRE debe ser 1.

### Parte 3 (métricas bajo carga)
- **El "ahá" del fallo**: el alumno tumba un broker y ve URP subir en Grafana.
  Es el momento más memorable del lab.

### Parte 4 (tour CC)
- **Honestidad sobre por qué no es práctico**: explicar la decisión sin
  rodeos. El alumno aprecia la transparencia.
- **Mostrar capturas reales**: no inventar pantallazos, usar la cuenta real
  del instructor.

### Parte 5 (comparativa)
- **No hay respuesta única**: cada herramienta tiene su lugar. La elección
  es de negocio, no técnica.

---

## Errores comunes de los alumnos

| Error | Solución |
|-------|---------|
| "Grafana no muestra datos" | Esperar 2-3 minutos para primera batch de métricas |
| Panel "No data" | Es esperado: el dashboard de la comunidad necesita ajustes |
| Targets DOWN al inicio | JMX Exporter tarda en arrancar (~30s tras el broker) |
| URP sube y no baja | Si tumbaste broker, esperar revivir y catch-up |

---

## Discusión grupal

1. **¿Por qué Prometheus es pull y no push?**
   - Pull es más simple para descubrimiento, debugging, y filosofía Unix
   - Push (OTLP) escala mejor a muchísimos sources
   - No hay respuesta universal; es preferencia arquitectónica

2. **Si pudieras quedarte con UNA herramienta para Kafka, ¿cuál?**
   - Sin contexto: Kafbat UI (es la más balanceada)
   - Con producción crítica: Cloud o CC
   - Con equipo de plataforma: Prometheus + Grafana

3. **¿Cómo escalar este stack a 100 brokers?**
   - Prometheus federation (varios servidores)
   - Thanos o Cortex para almacenamiento de largo plazo
   - Grafana sigue siendo uno (multi-datasource)
