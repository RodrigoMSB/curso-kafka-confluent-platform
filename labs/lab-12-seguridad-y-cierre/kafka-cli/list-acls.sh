#!/bin/bash
# Lista todas las ACLs del cluster.

set -euo pipefail
source "$(dirname "$0")/../bin/common.sh"

echo -e "${CYAN}[List ACLs] Todas las reglas de autorización${NC}"
echo "────────────────────────────────────────────────────────"

docker exec -e KAFKA_OPTS= cli-client kafka-acls \
    --bootstrap-server localhost:9092 \
    --command-config /etc/kafka/client-properties/admin.properties \
    --list
