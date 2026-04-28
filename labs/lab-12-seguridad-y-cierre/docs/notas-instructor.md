# Notas de instructor — Lab 12

## Objetivo del lab

Cerrar los puntos 9 y 10 del Capítulo 4 del curso (Seguridad + Capstone) cubriendo de forma práctica:

- TLS server-side (cifrado de tráfico cliente-broker)
- SASL/PLAIN (autenticación)
- ACLs con StandardAuthorizer (autorización)
- `min.insync.replicas` (durabilidad bajo fallos)
- RBAC (concepto, no se configura)
- Capstone integrador con Labs 09, 10 y 11

**Tiempo total estimado**: 2.5 - 3 horas (incluyendo capstone).

---

## Honestidad pedagógica — los 4 atajos que tomamos

Este lab toma decisiones pedagógicas que sacrifican fidelidad-a-producción a cambio de claridad. **Hay que mencionarlas explícitamente** durante la clase para que los alumnos no se vayan con conclusiones erradas.

### 1. SASL/PLAIN — credenciales en texto plano

**Lo que hicimos**: usamos `PlainLoginModule` con passwords visibles en `kafka_server_jaas.conf` y en las properties del cliente.

**Por qué es didáctico**: el alumno puede abrir un editor y leer las credenciales, entender la estructura del JAAS, y conectar el `user_<NAME>="<PASSWORD>"` con la regla SASL.

**Por qué NO sirve para producción**:
- Las passwords se transmiten al broker como texto plano (TLS las protege en el cable, pero quedan en logs si algo se desconfigura).
- Cualquier persona con acceso al broker o a un cliente puede leer las credenciales.
- Rotar passwords requiere reinicio del broker.

**Qué decir en clase**: *"En producción usen SCRAM-SHA-512 mínimo. Los users se crean con `kafka-configs --add-config 'SCRAM-SHA-512=[password=...]'` y se persisten en metadata. PLAIN se usa solo en demos y a veces detrás de un proxy gateway que termine TLS y traduzca a otro mecanismo internamente."*

---

### 2. TLS server-side, no mTLS

**Lo que hicimos**: el broker presenta su cert al cliente; el cliente verifica con la CA del truststore. Los clientes NO presentan cert.

**Por qué es didáctico**: una sola dirección de la conversación. Los alumnos ya pelean con keystore vs truststore; agregar el lado del cliente confunde.

**Por qué NO basta para producción de alta seguridad**:
- En mTLS el principal del cliente lo deriva el broker del CN del cert. Eso elimina la posibilidad de robo de password.
- En esquemas regulados (banca, salud), mTLS suele ser requerido por compliance.
- Sin mTLS la única defensa de identidad es SASL — y vimos que con PLAIN eso es frágil.

**Qué decir en clase**: *"mTLS es lo que recomendaría para inter-broker traffic en producción. El listener INTERNAL de este lab está en PLAINTEXT, lo que en una red Docker compartida es OK pero en una red corporativa con alguien capaz de hacer ARP poisoning sería un agujero. En producción: TLS en TODOS los listeners (incluido controller), mTLS para inter-broker, SASL para clientes externos."*

---

### 3. RBAC como concepto, no como práctica

**Lo que hicimos**: la Parte 5 explica RBAC sin configurarlo.

**Por qué**: RBAC vive en Confluent Server (Enterprise, licencia paga) y requiere MDS + integración LDAP/OAuth. Levantar un MDS + Active Directory simulado en Docker tomaría medio día solo de plomería YAML, sin ganancia pedagógica para Kafka core.

**Qué decir en clase**: *"Si están en Confluent Cloud o Confluent Enterprise on-prem, RBAC es lo que van a usar para grupos > 50 personas. Si están en Apache Kafka self-hosted, ACLs nativas + un repo Terraform para gestionarlas es lo realista. RBAC no es 'la versión correcta de ACLs', es una capa adicional con costo."*

Si un alumno pide ver RBAC en acción, mandalo a Confluent Cloud (`confluent iam rbac role-binding list`) o al docs link.

---

### 4. Kafbat UI sin autenticación

**Lo que hicimos**: Kafbat se conecta vía PLAINTEXT al listener INTERNAL, sin SASL, sin TLS. Y la UI misma no tiene login.

**Por qué**: la prioridad pedagógica de este lab es que el alumno vea las ACLs y los topics en una UI. Configurar Kafbat con SASL_SSL agrega 6 variables de entorno que distraen.

**Por qué NO sirve para producción**:
- Cualquiera con acceso a `localhost:8090` ve TODO el cluster, incluido contenido de mensajes que pueden tener PII.
- Kafbat se conecta como `User:ANONYMOUS` (super user en este lab). Si alguien encuentra cómo enviar requests vía Kafbat, bypassa todas las ACLs.

**Qué decir en clase**: *"En producción Kafbat va detrás de un reverse proxy con SSO (OAuth/OIDC). Y se conecta al cluster con un principal acotado, no como super user. La UI es una herramienta operacional, no un punto de seguridad."*

---

## Errores comunes y cómo destrabarlos

### "El truststore no existe" al levantar el cluster

Causa: `bin/start-lab.sh` corrió sin `bin/generate-certs.sh` previo, o el script de certs falló.

Solución:
```bash
bin/reset-lab.sh
bin/generate-certs.sh
bin/start-lab.sh
```

### "SaslAuthenticationException" en TODO

Causa: Java en el host modifica el JAAS global o el alumno copió mal las properties.

Solución: ejecutar siempre los scripts vía `docker exec cli-client` (los kafka-cli/*.sh ya lo hacen). No correrlos desde el host.

### Healthcheck eternamente "starting"

Causa: el listener EXTERNAL falla por cert mal generado y el broker no escucha en 9092.

Solución:
```bash
docker logs kafka-broker-1 2>&1 | grep -i "ssl\|sasl"
```

Si dice "Failed to load keystore", regenerar certs.

### El alumno produjo correctamente pero el consume no muestra nada

Causa: el `console-consumer` arranca leyendo desde `latest` por defecto. Si produjo antes de iniciar el consume, no ve esos mensajes.

Solución: agregar `--from-beginning` al script de consume, o decir al alumno que produzca DESPUÉS de iniciar el consume.

### "TopicAuthorizationException" producido como `app1`

Causa: las ACLs no se cargaron (init-lab12-acls.sh falló).

Solución:
```bash
docker logs cli-client 2>&1 | tail -20
# si no encuentras nada, re-ejecutar:
docker exec -e KAFKA_OPTS= cli-client /etc/kafka/scripts/init-lab12-acls.sh
```

---

## Sobre el capstone

El capstone NO duplica infraestructura: el alumno trabaja con los Labs 09, 10 y 11 levantados en sus respectivos compose. Eso significa que:

- Antes del capstone, asegúrate que los alumnos tengan **disco y RAM suficiente** para tener 4 stacks Docker corriendo en paralelo. Mínimo 16GB RAM.
- Si Docker Desktop tiene memoria asignada baja (default 2GB), van a tener OOM. Subir a 8GB mínimo.
- Usar `docker stats` para diagnosticar si algún container está siendo killed.

Si un alumno no tiene capacidad de máquina para levantar 4 stacks, dale la opción de **simular el flujo dentro de un solo lab** (insertar el JSON enriquecido directo al topic del Lab 10 con `produce-pedido.sh`). Pierde el "wow factor" pero conserva la lección de JOINs y observabilidad.

---

## Tiempos sugeridos por parte

| Parte | Tiempo |
|-------|--------|
| 1 — TLS y certificados | 25 min |
| 2 — SASL y autenticación | 20 min |
| 3 — ACLs y autorización | 25 min |
| 4 — min.insync.replicas | 30 min |
| 5 — RBAC concepto | 15 min |
| 6 — Capstone | 60 min |
| **Total** | **~2h 35min** |

Más 15 min de cierre y reflexión final → 3 horas.

---

## Recursos para profundizar (después del curso)

- KIP-500 (KRaft) → entender por qué desaparece ZooKeeper.
- KIP-851 (StandardAuthorizer) → cómo se implementan las ACLs en KRaft.
- Confluent docs: "Configure mTLS for Kafka brokers".
- Vault PKI o cert-manager → automatizar rotación de certs.
- Strimzi Operator (Kubernetes) → equivalente managed-style para K8s.
