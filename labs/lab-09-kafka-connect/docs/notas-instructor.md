# Notas para el Instructor - Lab 09

## Distribución de tiempo sugerida

| Parte | Tiempo |
|-------|--------|
| Setup (incluyendo descarga de imágenes y plugin JDBC) | 15 min |
| Parte 1: Arquitectura | 20 min |
| Parte 2: Source connector | 30 min |
| Parte 3: Sink connector | 25 min |
| Parte 4: Desafío end-to-end | 25 min |
| Discusión y cierre | 5 min |
| **Total** | **~120 min** |

---

## Antes de la clase (CRÍTICO)

Pre-descargar imágenes en TODAS las máquinas:

```bash
docker pull confluentinc/cp-kafka:8.2.0
docker pull confluentinc/cp-kafka-connect:8.2.0
docker pull postgres:16-alpine
docker pull ghcr.io/kafbat/kafka-ui:latest
```

**Importante**: el plugin JDBC (`confluentinc/kafka-connect-jdbc:10.8.0`) y el driver PostgreSQL (`postgresql-42.7.4.jar`) se descargan al arrancar el contenedor `kafka-connect`. Esto agrega ~60-90s al primer arranque y requiere acceso a internet.

---

## Honestidad pedagógica

Documentar EXPLÍCITAMENTE en clase:

1. **JDBC vs Debezium**: este lab usa JDBC porque es el connector más educativo para entender Connect. En producción real para CDC se usaría **Debezium** (lee el WAL de PostgreSQL, captura INSERT/UPDATE/DELETE en milisegundos). JDBC con `mode: incrementing` solo captura INSERTs y tiene latencia de polling (~5s en este lab).

2. **Plugin instalado al arrancar**: en producción se construye una imagen Docker custom con el plugin pre-instalado. Aquí lo instalamos al arrancar para mantener simplicidad pedagógica (un solo `bin/start-lab.sh` y arranca todo).

3. **Vuelta a CP 8.2.0**: el Lab 08 usó CP 7.9.0 por requisito de CC Legacy. El Lab 09 vuelve a 8.2.0 (Kafka 4.2) que es lo alineado al temario del curso.

---

## Puntos a enfatizar

### Parte 1
- **Connect es declarativo, no imperativo**: el alumno declara "qué" conectar, no "cómo". Esto es transformador.
- **Modo distributed**: aunque tenemos 1 worker, mostrar que la API REST es la misma con 1 o N workers.

### Parte 2
- **El momento "ahá"**: cuando el alumno hace INSERT en PostgreSQL y ve aparecer el mensaje en el consumer ~5s después. Detenerse a celebrar.
- **`mode: incrementing`**: explicar las limitaciones (solo INSERT). Es puente para mencionar Debezium en clase de Cap 5.

### Parte 3
- **Idempotencia con upsert**: clave para entender por qué Connect es resiliente. Re-publicar un mensaje no duplica.
- **Connector FAILED**: enseñar que esto es normal en producción. La habilidad clave es saber recuperar (`POST /connectors/<name>/restart`).

### Parte 4
- **Cero líneas de código**: enfatizar que esto es un cambio de paradigma. Los integraciones tradicionales requieren miles de líneas.

---

## Errores comunes

| Error | Solución |
|-------|---------|
| Connect tarda mucho en arrancar | 90-120s la primera vez (instala plugin). Esperar |
| Source falla con "table not found" | El init.sql no se ejecutó. `bin/reset-lab.sh` y reiniciar |
| Sink falla con "field 'id' missing" | Mensaje JSON sin `id`. Es esperado y enseña sobre validación |
| Tópico `novatech.lab09.pedidos` no se crea | Verificar que `auto.create.topics.enable: true` en brokers |
| Plugin JDBC no descarga | Sin internet en el contenedor. `docker logs kafka-connect | head -30` |

---

## Discusión grupal

1. **¿Cuándo usar Connect vs código custom?**
   - Connect: cuando hay un connector oficial para tu fuente/destino
   - Custom: cuando necesitas lógica de transformación compleja

2. **Modo standalone vs distributed**:
   - Standalone: dev local, demos
   - Distributed: producción, alta disponibilidad

3. **Single Message Transforms (SMT)**:
   - Mencionar que existen para transformaciones simples sin código
   - No los cubrimos en este lab pero son una herramienta poderosa
