# Notas para el Instructor - Lab 08

## Distribución de tiempo sugerida

| Parte | Tiempo |
|-------|--------|
| Setup (incluyendo descarga de imágenes la primera vez) | 15 min |
| Parte 1: Arquitectura | 15 min |
| Parte 2: Tour Control Center | 25 min |
| Parte 3: Métricas bajo carga | 20 min |
| Parte 4: Configurar alerta | 25 min |
| Parte 5: Desafío Kafbat vs CC (opcional) | 15 min |
| Discusión y cierre | 10 min |
| **Total** | **~125 min** |

---

## ⚠️ Antes de la clase (CRÍTICO)

**Pre-descargar las 4 imágenes en TODAS las máquinas de los alumnos.** Son ~3 GB total.

```bash
docker pull confluentinc/cp-server:8.2.0
docker pull confluentinc/cp-enterprise-prometheus:2.2.1
docker pull confluentinc/cp-enterprise-alertmanager:2.2.1
docker pull confluentinc/cp-enterprise-control-center-next-gen:2.2.1
docker pull ghcr.io/kafbat/kafka-ui:latest
```

Sin esto, los alumnos pasarán la primera media hora de clase descargando.

**Subir RAM Docker a 8 GB** en las máquinas de los alumnos. Settings > Resources > Memory > 8 GB > Apply & Restart.

**Detener Labs 01-07** antes de levantar el 08. Comparten puerto 9092-9094.

---

## Arquitectura de monitoreo (Lab 08)

Usamos **Confluent Control Center Legacy 7.9.0** con la arquitectura tradicional:

1. Cada broker (cp-server) emite métricas vía **ConfluentMetricsReporter** (un MetricReporter de Kafka que publica al tópico `_confluent-metrics` del propio clúster)
2. Control Center consume de `_confluent-metrics` y materializa los dashboards
3. Las alertas se configuran y disparan **dentro del propio CC** (sin Alertmanager externo)

Esta arquitectura está probada en producción desde Confluent Platform 4.x (años) y es la que usa el `cp-all-in-one` oficial.

### ¿Por qué no CC Next-Gen 2.x?

Confluent lanzó CC Next-Gen 2.x en 2025 con arquitectura basada en Prometheus + OTLP + Alertmanager. Esta versión:
- Es más escalable (soporta 400K particiones vs 120K de Legacy)
- Permite integración con Grafana
- Pero requiere setup más complejo: 3 servicios adicionales y configuración delicada del Telemetry Reporter

Probamos integrarla en este lab pero el escapado de variables de entorno en Docker tiene quirks no documentados que impiden el setup limpio. Para mantener la calidad pedagógica, usamos Legacy 7.9.0.

**Punto importante para el alumno**: los conceptos de monitoreo (qué medir, alertas, troubleshooting) son idénticos entre Legacy y Next-Gen. Lo único que cambia es la implementación interna.

### Pre-descarga de imágenes

Antes de la clase, ejecutar:
```bash
docker pull confluentinc/cp-server:7.9.0
docker pull confluentinc/cp-enterprise-control-center:7.9.0
```

(Ya no se necesitan las imágenes de Prometheus/Alertmanager).

### Si los dashboards de CC quedan vacíos

Primer lugar a revisar:
- ¿Las variables `KAFKA_METRIC_REPORTERS=io.confluent.metrics.reporter.ConfluentMetricsReporter` están en los 3 brokers?
- ¿El tópico `_confluent-metrics` existe? (`kafka-topics --list | grep _confluent`)
- ¿`auto.create.topics.enable=true`?
- ¿La imagen es `cp-server:7.9.0` (NO `cp-kafka`)?

---

## Honestidad pedagógica

Documentar EXPLÍCITAMENTE en clase:

1. **Configuración de evaluación**: este lab usa el período de prueba de Confluent Platform 8.2 con CC Next-Gen 2.2.1. Para producción real, hace falta licencia comercial.

2. **Stack simplificado**: NO desplegamos Schema Registry, Connect ni ksqlDB para mantener foco en monitoreo. En producción real serían parte de la suite.

3. **Alertas de 30s**: el experimento usa duración corta para que la clase quepa en tiempo. En producción real, las alertas se evalúan en 5-15 minutos para evitar false positives.

4. **License de cp-server**: viene con período de evaluación. Cada vez que se reinicia el clúster, el período se reinicia.

---

## Puntos a enfatizar

### Parte 1
- **`cp-server` vs `cp-kafka`**: el alumno debe entender que NO es solo "una imagen distinta". Es la diferencia entre "open source" y "enterprise".
- **OTLP**: protocolo moderno, futuro estándar. Mostrar que Confluent ya lo adoptó.

### Parte 2
- **Tomarse tiempo en cada pestaña**: muchos alumnos hacen click rápido sin observar. Pausar y leer cada gráfico.
- **Tópicos `_confluent-*`**: aclarar que CC los crea automáticamente. NO eliminarlos.

### Parte 3
- **Carga sostenida es CRÍTICA**: sin carga, los dashboards están en 0 y todo parece roto. La carga es lo que da vida al lab.
- **Diferencia entre Production Rate y Consumption Rate**: no son siempre iguales. Hay un consumer interno de CC que consume métricas.

### Parte 4
- **Tiempo de detección 30-60s es normal**: si el alumno tumba el broker y la alerta no aparece en 5 segundos, NO está roto. Es por diseño.
- **Verificar en 3 lugares (CC + Alertmanager + Prometheus)**: refuerza que es un PIPELINE, no una UI mágica.

### Parte 5
- **No es "Kafbat es peor"**: es "cada uno tiene su lugar". Reforzar.

---

## Errores comunes de los alumnos

| Error | Solución |
|-------|---------|
| "Control Center está vacío" | Esperar 2-3 minutos. La primera vez tarda en propagarse el primer batch de métricas |
| "La alerta no aparece" | Verificar que la duración es 30s (no 0). Verificar que tumbó realmente el broker (`docker ps`) |
| "Docker se queda sin RAM" | Subir a 8 GB en Docker Desktop Settings |
| "Imagen no descarga" | Verificar credenciales de Docker (algunas imágenes requieren login a `docker.io`) |
| "Conflicto de puertos" | Detener Labs 01-07 (comparten 9092-9094, 8090) |

---

## Discusión grupal

1. **¿Por qué OTLP es el futuro?**
   - Estándar abierto (no propietario), un solo protocolo para métricas + traces + logs.
   - Adopción creciente por Apache, Confluent, Cloud providers.

2. **CC es caro. ¿Cuándo realmente lo necesitas?**
   - Cuando RBAC es requerimiento (compliance).
   - Cuando tienes equipo NOC dedicado que necesita dashboards profesionales.
   - Cuando vas a integrar Schema Registry / Connect / ksqlDB y quieres una sola consola.

3. **¿Existe un "Kafbat" de pago con alertas?**
   - Sí: Conduktor, Kafka Magic, AKHQ con plugins. Alternativas a Kafbat con más features.
   - Hablar de la elección como un espectro, no binario.
