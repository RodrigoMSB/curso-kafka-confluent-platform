# Soluciones de referencia — Curso Kafka NovaTech

Material de referencia con las soluciones de los 12 laboratorios del
curso "Administración de Apache Kafka con Confluent Platform".

## Cómo usar este material

1. Cada lab tiene su carpeta `soluciones/` con respuestas modelo.
2. Intenta resolver primero por tu cuenta usando la guía del lab.
3. Consulta las soluciones para validar tu trabajo o destrabarte.

## Índice

| Lab | Tema | Soluciones |
|-----|------|-----------|
| 01 | Radiografía del clúster | [`lab-01/soluciones/`](lab-01-radiografia-cluster/soluciones/README.md) |
| 02 | Pub/Sub en acción | [`lab-02/soluciones/`](lab-02-pubsub-en-accion/soluciones/README.md) |
| 03 | Construye tu propio clúster KRaft | [`lab-03/soluciones/`](lab-03-construye-tu-cluster/soluciones/README.md) |
| 04 | Operando tópicos | [`lab-04/soluciones/`](lab-04-operando-topicos/soluciones/README.md) |
| 05 | Resiliencia y retención | [`lab-05/soluciones/`](lab-05-resiliencia-y-retencion/soluciones/README.md) |
| 06 | Productores afilados | [`lab-06/soluciones/`](lab-06-productores-afilados/soluciones/README.md) |
| 07 | Consumer groups bajo presión | [`lab-07/soluciones/`](lab-07-consumer-groups-bajo-presion/soluciones/README.md) |
| 08 | Monitoreo con Control Center | [`lab-08/soluciones/`](lab-08-monitoreo-control-center/soluciones/README.md) |
| 09 | Kafka Connect | [`lab-09/soluciones/`](lab-09-kafka-connect/soluciones/README.md) |
| 10 | Schema Registry y ksqlDB | [`lab-10/soluciones/`](lab-10-schema-registry-ksqldb/soluciones/README.md) |
| 11 | Prometheus y Grafana | [`lab-11/soluciones/`](lab-11-prometheus-grafana/soluciones/README.md) |
| 12 | Seguridad y capstone final | [`lab-12/soluciones/`](lab-12-seguridad-y-cierre/soluciones/README.md) |

## Stack del curso

- Apache Kafka 4.2 con KRaft (sin ZooKeeper)
- Confluent Platform 8.2.0
- OpenJDK 21 (Temurin)
- Docker Compose

> Lab 08 usa CP 7.9.0 / Kafka 3.7 puntualmente porque Control Center
> Legacy requiere esa versión. El resto del curso usa CP 8.2.0.

## Notas finales

Si encuentras un error en alguna solución o tienes una mejor respuesta,
abre un issue o un PR en el repositorio.
