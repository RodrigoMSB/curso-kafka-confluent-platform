#!/bin/bash
set -euo pipefail

# ============================================================
# NovaTech Logistics - Lab 09: Iniciar laboratorio
# ============================================================

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Directorio base del laboratorio
LAB_DIR="$(cd "$(dirname "$0")/.." && pwd)"
COMPOSE_FILE="${LAB_DIR}/infra/docker-compose.yml"
ENV_FILE="${LAB_DIR}/infra/.env"

# Banner
echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                                                          ║"
echo "║     ███╗   ██╗ ██████╗ ██╗   ██╗ █████╗                 ║"
echo "║     ████╗  ██║██╔═══██╗██║   ██║██╔══██╗                ║"
echo "║     ██╔██╗ ██║██║   ██║██║   ██║███████║                ║"
echo "║     ██║╚██╗██║██║   ██║╚██╗ ██╔╝██╔══██║                ║"
echo "║     ██║ ╚████║╚██████╔╝ ╚████╔╝ ██║  ██║                ║"
echo "║     ╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚═╝  ╚═╝                ║"
echo "║              T E C H   L O G I S T I C S                ║"
echo "║                                                          ║"
echo "║     Lab 09: Kafka Connect con PostgreSQL                 ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificar que Docker está corriendo
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}[ERROR] Docker no está corriendo. Por favor, inicia Docker Desktop.${NC}"
    exit 1
fi

DOCKER_MEM=$(docker info --format '{{.MemTotal}}' 2>/dev/null || echo "0")
DOCKER_MEM_GB=$((DOCKER_MEM / 1073741824))
if [ "$DOCKER_MEM_GB" -lt 5 ]; then
    echo -e "${YELLOW}[ADVERTENCIA] Docker tiene ${DOCKER_MEM_GB} GB de RAM asignados.${NC}"
    echo -e "${YELLOW}  Se recomiendan al menos 6 GB para este laboratorio.${NC}"
fi

echo -e "${YELLOW}[1/6] Levantando contenedores del clúster NovaTech Lab 09...${NC}"
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d

echo ""
echo -e "${YELLOW}[2/6] Esperando a que los 3 brokers estén operativos...${NC}"

TIMEOUT=180
ELAPSED=0
BROKERS_READY=0

while [ "$BROKERS_READY" -lt 3 ] && [ "$ELAPSED" -lt "$TIMEOUT" ]; do
    BROKERS_READY=0
    for BROKER in kafka-broker-1 kafka-broker-2 kafka-broker-3; do
        STATUS=$(docker inspect --format='{{.State.Health.Status}}' "$BROKER" 2>/dev/null || echo "not_found")
        if [ "$STATUS" = "healthy" ]; then
            BROKERS_READY=$((BROKERS_READY + 1))
        fi
    done

    if [ "$BROKERS_READY" -lt 3 ]; then
        echo -e "${YELLOW}  ${BROKERS_READY}/3 brokers listos... (${ELAPSED}s/${TIMEOUT}s)${NC}"
        sleep 5
        ELAPSED=$((ELAPSED + 5))
    fi
done

if [ "$BROKERS_READY" -lt 3 ]; then
    echo -e "${RED}[ERROR] Timeout: solo ${BROKERS_READY}/3 brokers operativos.${NC}"
    exit 1
fi

echo -e "${GREEN}  ✓ 3/3 brokers operativos${NC}"

echo ""
echo -e "${YELLOW}[3/6] Esperando a que Kafbat UI esté disponible...${NC}"

UI_TIMEOUT=60
UI_ELAPSED=0
while [ "$UI_ELAPSED" -lt "$UI_TIMEOUT" ]; do
    if curl -sf http://localhost:8090/actuator/health > /dev/null 2>&1; then
        break
    fi
    echo -e "${YELLOW}  Kafbat UI iniciando... (${UI_ELAPSED}s/${UI_TIMEOUT}s)${NC}"
    sleep 5
    UI_ELAPSED=$((UI_ELAPSED + 5))
done

if [ "$UI_ELAPSED" -ge "$UI_TIMEOUT" ]; then
    echo -e "${YELLOW}  [INFO] Kafbat UI tarda. Verificable en http://localhost:8090${NC}"
else
    echo -e "${GREEN}  ✓ Kafbat UI disponible${NC}"
fi

echo ""
echo -e "${YELLOW}[4/6] Esperando a que PostgreSQL esté disponible...${NC}"

PG_TIMEOUT=60
PG_ELAPSED=0
while [ "$PG_ELAPSED" -lt "$PG_TIMEOUT" ]; do
    if docker exec postgres pg_isready -U novatech -d novatech_orders > /dev/null 2>&1; then
        break
    fi
    echo -e "${YELLOW}  PostgreSQL iniciando... (${PG_ELAPSED}s/${PG_TIMEOUT}s)${NC}"
    sleep 3
    PG_ELAPSED=$((PG_ELAPSED + 3))
done

if [ "$PG_ELAPSED" -ge "$PG_TIMEOUT" ]; then
    echo -e "${RED}[ERROR] PostgreSQL no responde. Revisa: docker logs postgres${NC}"
    exit 1
fi

echo -e "${GREEN}  ✓ PostgreSQL disponible${NC}"

echo ""
echo -e "${YELLOW}[5/6] Esperando a Kafka Connect (instala plugin JDBC, puede tardar 90-120s)...${NC}"

CONNECT_TIMEOUT=180
CONNECT_ELAPSED=0
while [ "$CONNECT_ELAPSED" -lt "$CONNECT_TIMEOUT" ]; do
    if curl -sf http://localhost:8083/connectors > /dev/null 2>&1; then
        break
    fi
    echo -e "${YELLOW}  Kafka Connect iniciando... (${CONNECT_ELAPSED}s/${CONNECT_TIMEOUT}s)${NC}"
    sleep 10
    CONNECT_ELAPSED=$((CONNECT_ELAPSED + 10))
done

if [ "$CONNECT_ELAPSED" -ge "$CONNECT_TIMEOUT" ]; then
    echo -e "${YELLOW}  [ADVERTENCIA] Connect aún no responde. Verifica: docker logs kafka-connect${NC}"
else
    echo -e "${GREEN}  ✓ Kafka Connect disponible (REST API en :8083)${NC}"
fi

echo ""
echo -e "${YELLOW}[6/6] Verificando datos seed en PostgreSQL...${NC}"

SEED_COUNT=$(docker exec postgres psql -U novatech -d novatech_orders -tAc "SELECT COUNT(*) FROM pedidos;" 2>/dev/null | tr -d '[:space:]' || echo "0")

if [ "$SEED_COUNT" = "5" ]; then
    echo -e "${GREEN}  ✓ ${SEED_COUNT} pedidos seed en la tabla 'pedidos'${NC}"
else
    echo -e "${YELLOW}  [INFO] Pedidos seed: ${SEED_COUNT} (esperado: 5)${NC}"
fi

# Crear el tópico del Sink (el Source crea el suyo solo)
bash "$(dirname "$0")/../infra/scripts/init-lab09-topics.sh"

echo ""
echo -e "${GREEN}${BOLD}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  CLÚSTER NOVATECH LAB 09 OPERATIVO${NC}"
echo -e "${GREEN}${BOLD}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}  Componentes:${NC}"
echo -e "    Broker 1:           localhost:9092"
echo -e "    Broker 2:           localhost:9093"
echo -e "    Broker 3:           localhost:9094"
echo -e "    Kafbat UI:          http://localhost:8090"
echo -e "    PostgreSQL:         localhost:5432  (user: novatech, db: novatech_orders)"
echo -e "    ${BOLD}Kafka Connect:      http://localhost:8083${NC}    ← REST API"
echo ""
echo -e "${CYAN}  PostgreSQL:${NC}"
echo -e "    5 pedidos seed creados en la tabla 'pedidos'"
echo -e "    Tabla 'pedidos_procesados' creada vacía"
echo ""
echo -e "${CYAN}  Próximos pasos:${NC}"
echo -e "    1. Crear el Source connector:  ${BOLD}connect-cli/create-source.sh${NC}"
echo -e "    2. Verificar tópico creado:    ${BOLD}kafka-cli/list-topics.sh${NC}"
echo -e "    3. Consumir pedidos:           ${BOLD}kafka-cli/consume-pedidos.sh${NC}"
echo ""
echo -e "${YELLOW}  Abre la guía: guia/01-arquitectura-connect.md${NC}"
echo ""
