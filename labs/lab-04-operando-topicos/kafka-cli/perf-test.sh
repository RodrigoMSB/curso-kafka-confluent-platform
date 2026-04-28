#!/bin/bash
# Wrapper de kafka-producer-perf-test para medir throughput real del broker.

set -euo pipefail
source "$(dirname "$0")/../bin/common.sh"
resolve_broker

if [ $# -lt 2 ]; then
    cat <<EOF
Uso: $0 <TOPICO> <NUM_MENSAJES> [TAMAÑO_BYTES]

Genera carga sintética y mide throughput real.
TAMAÑO_BYTES default: 200 bytes (similar a un evento JSON GPS)

Ejemplos:
  $0 novatech.gps.realtime 10000
  $0 novatech.audit.events 5000 500
EOF
    exit 1
fi

TOPIC="$1"
NUM_RECORDS="$2"
RECORD_SIZE="${3:-200}"

echo -e "${CYAN}[Perf Test] ${TOPIC}${NC}"
echo "  Mensajes:  ${NUM_RECORDS}"
echo "  Tamaño:    ${RECORD_SIZE} bytes"
echo "  Throughput target: -1 (sin límite)"
echo "────────────────────────────────────────────────────────"

docker exec "$BROKER" kafka-producer-perf-test \
    --topic "$TOPIC" \
    --num-records "$NUM_RECORDS" \
    --record-size "$RECORD_SIZE" \
    --throughput -1 \
    --producer-props bootstrap.servers="$BOOTSTRAP" acks=all
