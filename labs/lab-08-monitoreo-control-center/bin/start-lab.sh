#!/bin/bash
set -euo pipefail

# ============================================================
# NovaTech Logistics - Lab 08: Iniciar laboratorio
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
echo "║     Lab 08: Monitoreo con Control Center (Legacy 7.9)    ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificar que Docker está corriendo
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}[ERROR] Docker no está corriendo. Por favor, inicia Docker Desktop.${NC}"
    exit 1
fi

# Verificar memoria disponible (mínimo 6 GB)
DOCKER_MEM=$(docker info --format '{{.MemTotal}}' 2>/dev/null || echo "0")
DOCKER_MEM_GB=$((DOCKER_MEM / 1073741824))
if [ "$DOCKER_MEM_GB" -lt 5 ]; then
    echo -e "${RED}[ADVERTENCIA] Docker tiene ${DOCKER_MEM_GB} GB de RAM asignados.${NC}"
    echo -e "${RED}  Este lab requiere AL MENOS 6 GB. Subir en Docker Desktop > Settings > Resources.${NC}"
fi

echo -e "${YELLOW}[1/6] Levantando contenedores del clúster NovaTech Lab 08...${NC}"
# Cleanup defensivo: eliminar contenedores y volúmenes residuales de
# corridas previas (incluyendo posibles datos huérfanos de otros labs).
# El "|| true" evita que falle si no había nada que apagar.
docker compose -f "$COMPOSE_FILE" down -v --remove-orphans 2>/dev/null || true

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
    echo -e "${RED}  Revisa logs con: docker compose -f ${COMPOSE_FILE} logs${NC}"
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
echo -e "${YELLOW}[4/6] Verificando productor GPS...${NC}"
sleep 5
if docker ps --filter "name=gps-producer" --filter "status=running" --format "{{.Names}}" | grep -q "gps-producer"; then
    echo -e "${GREEN}  ✓ Productor GPS activo${NC}"
else
    echo -e "${YELLOW}  [INFO] El productor GPS está iniciando...${NC}"
fi

echo ""
echo -e "${YELLOW}[5/6] Esperando a Control Center (puede tardar 60-120s)...${NC}"

CC_TIMEOUT=180
CC_ELAPSED=0
while [ "$CC_ELAPSED" -lt "$CC_TIMEOUT" ]; do
    if curl -sf http://localhost:9021/healthcheck > /dev/null 2>&1 || curl -sf http://localhost:9021/ > /dev/null 2>&1; then
        break
    fi
    echo -e "${YELLOW}  Control Center iniciando... (${CC_ELAPSED}s/${CC_TIMEOUT}s)${NC}"
    sleep 10
    CC_ELAPSED=$((CC_ELAPSED + 10))
done

if [ "$CC_ELAPSED" -ge "$CC_TIMEOUT" ]; then
    echo -e "${YELLOW}  [ADVERTENCIA] Control Center aún no responde. Puede tardar más.${NC}"
    echo -e "${YELLOW}  Verificable manualmente en: http://localhost:9021${NC}"
else
    echo -e "${GREEN}  ✓ Control Center disponible${NC}"
fi

echo ""
echo -e "${YELLOW}[6/6] Inicializando tópicos del Lab 08...${NC}"
bash "$(dirname "$0")/../infra/scripts/init-lab08-topics.sh"

echo ""
echo -e "${GREEN}${BOLD}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  CLÚSTER NOVATECH LAB 08 OPERATIVO${NC}"
echo -e "${GREEN}${BOLD}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}  Componentes:${NC}"
echo -e "    Broker 1:           localhost:9092"
echo -e "    Broker 2:           localhost:9093"
echo -e "    Broker 3:           localhost:9094"
echo -e "    Kafbat UI:          http://localhost:8090"
echo -e "    ${BOLD}Control Center:     http://localhost:9021${NC}    ← LA ESTRELLA DEL LAB"
echo ""
echo -e "${CYAN}  Tópicos del Lab 08:${NC}"
echo -e "    ${BOLD}novatech.lab08.transactions${NC}   - 12 particiones, para carga"
echo -e "    ${BOLD}novatech.lab08.alerts${NC}         - 3 particiones, para alertas"
echo ""
echo -e "${CYAN}  Comandos útiles:${NC}"
echo -e "    Generar carga:          ${BOLD}kafka-cli/produce-flood.sh${NC}"
echo -e "    Tumbar broker (alarma): ${BOLD}kafka-cli/trigger-broker-down.sh <1|2|3>${NC}"
echo -e "    Detener laboratorio:    ${BOLD}bin/stop-lab.sh${NC}"
echo ""
echo -e "${YELLOW}  Abre la guía: guia/01-arquitectura-monitoreo.md${NC}"
echo ""
