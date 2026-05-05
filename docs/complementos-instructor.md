# Complementos para el instructor

> Documento vivo que cubre temas que pueden surgir durante el dictado
> del curso y que NO están (o están parcialmente) en los 6 PDFs de la
> serie de estudio. Se actualiza a medida que aparecen huecos.

## Convenciones

- Cada tema tiene su sección con título descriptivo
- Cada sección incluye: pregunta gatillo, respuesta corta, profundización,
  configs relacionadas, qué decir al alumno
- Las preguntas gatillo son las que un alumno realmente preguntaría
- Mantener tono conversacional, ejemplos concretos

## Índice

1. [Elección de líder de partición](#1-elección-de-líder-de-partición)

---

## 1. Elección de líder de partición

### Pregunta gatillo
"Si tumbamos el broker que es líder de una partición, ¿qué criterio usa
Kafka para elegir el nuevo líder? ¿Es configurable?"

### Respuesta corta
Kafka elige el primer broker vivo de la lista de Replicas que esté en el
ISR. Es automático, sin intervención humana, toma 1-3 segundos. Sí es
configurable en varios niveles.

### Profundización

**El criterio por defecto: "preferred leader election"**

Cuando creás un topic con replication factor 3, Kafka asigna 3 brokers a
cada partición y los lista en un orden específico. Por ejemplo:

  Partition 0    Replicas: 3,1,2    Isr: 1,2,3

El primero de la lista de Replicas (broker 3) es el "preferred leader":
el broker que Kafka prefiere como líder cuando el clúster está sano.

Si el preferred (broker 3) cae:
- El controller mira qué brokers de la lista Replicas están vivos Y en
  el ISR
- Elige el primero de la lista que cumpla ambas condiciones
- En el ejemplo: el siguiente sería el broker 1, que está en ISR → broker
  1 se vuelve líder
- Tiempo total de elección: 1-3 segundos

**Por qué existe el preferred leader**

Kafka distribuye los preferreds de forma uniforme entre los brokers para
que la carga de liderazgo sea balanceada. Por ejemplo, en un topic de 6
particiones:

  Partition 0: preferred broker 1
  Partition 1: preferred broker 2
  Partition 2: preferred broker 3
  Partition 3: preferred broker 1
  Partition 4: preferred broker 2
  Partition 5: preferred broker 3

Cada broker es preferred de 2 particiones. Si todos los brokers están
vivos y el clúster es estable, cada uno tiene exactamente 2 particiones
como líder. Carga pareja.

**El caso especial: todo el ISR cae**

Si TODOS los brokers del ISR caen al mismo tiempo (escenario raro pero
posible), Kafka tiene un dilema:

- OPCIÓN A: esperar hasta que vuelva alguien del ISR. La partición queda
  sin líder, no acepta lecturas ni escrituras. No se pierden datos pero
  el sistema queda parado.
- OPCIÓN B: promover a un broker que estaba FUERA del ISR (uno
  desactualizado). El sistema sigue funcionando pero se pierden los
  mensajes que el líder anterior tenía y este no.

Esto se controla con la config `unclean.leader.election.enable`:
- false (default, recomendado producción): opción A. Disponibilidad
  sacrificada por durabilidad.
- true: opción B. Durabilidad sacrificada por disponibilidad.

### Configs relacionadas

| Config | Default | Qué hace |
|---|---|---|
| `unclean.leader.election.enable` | false | Permite promover réplicas fuera del ISR. true = peligroso |
| `auto.leader.rebalance.enable` | true | Devuelve liderazgos al preferred cuando los brokers vuelven |
| `leader.imbalance.check.interval.seconds` | 300 | Cada cuánto el controller revisa si hay desbalance |
| `leader.imbalance.per.broker.percentage` | 10 | Cuánto desbalance tolerar antes de rebalancear |

### Reasignación manual

Si un administrador quiere forzar quién es líder de qué partición (caso
raro: rebalanceo después de agregar brokers, retiro de broker para
mantenimiento), se hace con la herramienta:

  kafka-reassign-partitions --bootstrap-server ... \
      --reassignment-json-file plan.json --execute

Es intervención manual. No se hace en operación normal.

### Qué decir al alumno en clase

"Cuando el líder cae, Kafka elige uno nuevo del ISR siguiendo un orden
de preferencia. Esto es automático y rápido, 1-3 segundos. Pero hay un
caso límite: ¿qué pasa si TODO el ISR cae? Por defecto, Kafka prefiere
quedarse sin líder antes que perder datos. Esa decisión es configurable
con unclean.leader.election.enable, y es una de las decisiones de
durabilidad más importantes que un administrador toma."

### Demostrable en Lab 01

Sí. Cuando el alumno haga `bin/kill-broker.sh 3`, puede ver la elección
de nuevo líder ejecutando antes y después:

  bin/explore-cluster.sh

Comparar el campo "Leader" de cada partición antes y después de matar
el broker.

---

PRÓXIMOS TEMAS A AGREGAR (lista provisional, vamos completando a medida
que aparecen):

- [ ] (vacío por ahora)

---
