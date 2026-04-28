# Rúbrica — evaluación final Lab 12

> Para uso del instructor o auto-evaluación. La nota es referencial; lo importante es identificar qué dominó el alumno y qué quedó pendiente.

## Escala

| Nivel | Significado |
|-------|-------------|
| **0** | No logrado / no respondió / respuesta incorrecta |
| **1** | Parcial — la idea está pero hay imprecisión técnica importante |
| **2** | Sólido — explica con vocabulario correcto y conecta los conceptos |

Total máximo: **20 puntos** (10 criterios × 2).

---

## Criterios

### 1. TLS server-side (2 pts)

| 0 | No identifica qué es un truststore o lo confunde con keystore |
| 1 | Explica truststore vs keystore pero no entiende `endpoint.identification.algorithm` vacío |
| 2 | Explica el flujo completo (CA firma cert broker → cliente verifica con CA del truststore) y justifica por qué basta server-side en este lab |

---

### 2. SASL/PLAIN — autenticación (2 pts)

| 0 | No distingue authn de authz |
| 1 | Identifica el JAAS y los users pero no entiende qué hace `super.users` |
| 2 | Explica por qué `User:ANONYMOUS` está como super user (inter-broker en listener PLAINTEXT) |

---

### 3. Diferencia AuthN vs AuthZ (2 pts)

Pregunta clave: ¿qué error aparece sin SASL vs con SASL pero sin ACL?

| 0 | No distingue los dos errores |
| 1 | Reconoce los dos errores pero no explica el momento del handshake en que ocurren |
| 2 | `SaslAuthenticationException` = falla de identidad (handshake SASL); `TopicAuthorizationException` = identidad OK, falla en authorizer post-handshake |

---

### 4. ACLs (2 pts)

| 0 | No sabe escribir un comando `kafka-acls` |
| 1 | Escribe el comando pero olvida `--group '*'` para consumer |
| 2 | Comando completo y correcto, justifica `allow.everyone.if.no.acl.found=false` |

---

### 5. min.insync.replicas — comportamiento (2 pts)

| 0 | No predice qué pasa al detener brokers |
| 1 | Predice correctamente con 2 vivos pero no entiende qué pasa con 1 vivo |
| 2 | Explica que con ISR < min.ISR el cluster bloquea escrituras (no pierde datos) y aplica la regla `RF = min.ISR + 1` |

---

### 6. RBAC vs ACL (2 pts)

| 0 | Cree que RBAC es "ACLs versión 2" |
| 1 | Identifica algunas diferencias (roles, grupos) pero no menciona cobertura más allá de Kafka |
| 2 | Explica los 3 aportes (roles predefinidos, cobertura SR/Connect/ksqlDB, integración con LDAP/SSO) y cuándo NO justifica usarlo |

---

### 7. Capstone — Desafío 1 (Connect → Kafka) (2 pts)

| 0 | No logró que el pedido aparezca en el topic |
| 1 | Apareció pero no diagnosticó el connector ni la task |
| 2 | Pipeline funciona, identifica id/partición y verifica estado RUNNING del connector |

---

### 8. Capstone — Desafío 2 (JOIN ksqlDB) (2 pts)

| 0 | No creó el STREAM derivado |
| 1 | Lo creó pero no entiende co-particionamiento |
| 2 | STREAM derivado funcionando + explica co-particionamiento (mismo número partitions, misma key) |

---

### 9. Capstone — Desafío 3 (Grafana) (2 pts)

| 0 | No abrió Grafana o no encontró paneles relevantes |
| 1 | Identifica consumer groups pero no propone métrica para detectar broker caído |
| 2 | Consumer groups identificados, métrica `up{job=...}` o `underreplicatedpartitions` mencionada |

---

### 10. Capstone — Desafío 4 (diseño seguro del pipeline) (2 pts)

| 0 | Respuesta vaga ("usar TLS y autenticación") |
| 1 | Aplica seguridad a 1-2 componentes pero no a todos |
| 2 | Detalla cambios concretos por componente: principal por servicio, ACLs específicas, super.users acotado, mTLS inter-broker, rotación de certs |

---

## Interpretación de la nota total

| Total | Lectura |
|-------|---------|
| **18-20** | Dominio sólido. Listo para llevar Kafka a producción con supervisión. Considerar certificación CCDAK. |
| **14-17** | Buena base. Conoce los conceptos pero falta práctica en operación. Necesita 1-2 proyectos reales antes de prod. |
| **10-13** | Sabe lo básico. Le falta integrar conceptos. Recomendar repasar Labs 06 (transacciones) + 12 (seguridad). |
| **6-9** | Tiene huecos importantes. Volver a Labs 03-05 antes de avanzar. |
| **< 6** | Empezó pero no consolidó. Repaso desde Lab 01. |

---

## Banderas rojas (independiente del puntaje)

Si el alumno comete cualquiera de estos errores, **mencionarlo aunque su nota sea alta**:

- **Confunde TLS con autenticación** ("ya tengo TLS, no necesito SASL"). Falso: TLS protege la red, no la identidad.
- **Cree que `super.users` es para "el admin del sistema"**. En realidad es para CUALQUIER principal que se quiera saltar las ACLs — debe usarse con extrema reserva.
- **Recomienda `min.ISR=replication.factor`**. Eso destruye la disponibilidad. La regla práctica es `RF = min.ISR + 1`.
- **Olvida que las ACLs son por principal + recurso + operación + host**, y propone una ACL "global". No existen ACLs globales en Kafka.
- **Cree que RBAC es Apache Kafka**. RBAC es Confluent Enterprise — confundirlo cuando un alumno trabaje en Apache Kafka self-hosted le va a costar tiempo de búsqueda.

Mencionar las banderas rojas en el feedback es más valioso que la nota.
