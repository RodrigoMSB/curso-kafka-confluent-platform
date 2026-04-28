#!/bin/bash
# Consume mensajes Avro y los muestra como JSON usando kafka-avro-console-consumer.

set -euo pipefail
source "$(dirname "$0")/../bin/common.sh"

TOPIC="${1:?Uso: $0 <topic>}"

echo -e "${CYAN}[Consume Avro] Tópico: ${TOPIC}${NC}"
echo "  Presiona Ctrl+C para detener"
echo "────────────────────────────────────────────────────────"

docker exec -it schema-registry kafka-avro-console-consumer \
  --bootstrap-server kafka-broker-1:29092 \
  --topic "$TOPIC" \
  --from-beginning \
  --property schema.registry.url=http://schema-registry:8081
