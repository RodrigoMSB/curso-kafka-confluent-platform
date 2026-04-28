#!/bin/bash
set -euo pipefail

echo "[init-lab12-acls] Creando ACLs del Lab 12..."

# app1: producer+consumer sobre publico
docker exec -e KAFKA_OPTS= cli-client kafka-acls \
    --bootstrap-server localhost:9092 \
    --command-config /etc/kafka/client-properties/admin.properties \
    --add --allow-principal User:app1 \
    --producer --consumer --group '*' \
    --topic novatech.lab12.publico

# app1: producer+consumer sobre confidencial
docker exec -e KAFKA_OPTS= cli-client kafka-acls \
    --bootstrap-server localhost:9092 \
    --command-config /etc/kafka/client-properties/admin.properties \
    --add --allow-principal User:app1 \
    --producer --consumer --group '*' \
    --topic novatech.lab12.confidencial

# app2: SOLO consumer sobre publico (NO confidencial; eso es la prueba)
docker exec -e KAFKA_OPTS= cli-client kafka-acls \
    --bootstrap-server localhost:9092 \
    --command-config /etc/kafka/client-properties/admin.properties \
    --add --allow-principal User:app2 \
    --consumer --group '*' \
    --topic novatech.lab12.publico

echo "✓ ACLs creadas:"
echo "  app1 → producer+consumer sobre publico Y confidencial"
echo "  app2 → SOLO consumer sobre publico (sin acceso a confidencial)"
