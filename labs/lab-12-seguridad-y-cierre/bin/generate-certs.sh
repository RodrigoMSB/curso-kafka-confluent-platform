#!/bin/bash
# Genera CA + certificados de servidor para los 3 brokers Kafka.
# Usado para TLS en listener cliente (SASL_SSL://).
#
# Portabilidad: openssl corre en el host (Git Bash en Windows lo trae,
# macOS/Linux lo tienen preinstalado). keytool corre dentro de un contenedor
# eclipse-temurin:21-jdk para eliminar la dependencia de Java en el host.

set -euo pipefail
source "$(dirname "$0")/common.sh"

CERTS_DIR="$(cd "$(dirname "$0")/../infra/certs" && pwd)"
PASS="${TLS_KEYSTORE_PASSWORD:-changeit}"
DAYS=3650
CN_CA="NovaTech-CA-Lab12"
KEYTOOL_IMAGE="eclipse-temurin:21-jdk"

mkdir -p "$CERTS_DIR"

# Idempotencia: si ya existen, salir
if [[ -f "$CERTS_DIR/ca.crt" ]]; then
    echo -e "${YELLOW}Los certificados ya existen en $CERTS_DIR. Saltando generación.${NC}"
    echo -e "${YELLOW}Para regenerar: borrar el directorio infra/certs/ y volver a ejecutar.${NC}"
    exit 0
fi

# Wrapper: ejecuta keytool dentro de un contenedor eclipse-temurin:21-jdk
# montando $CERTS_DIR como /certs. Los paths que se pasen a keytool deben
# referirse a /certs/<archivo>, no a la ruta del host.
run_keytool() {
    docker run --rm \
        -v "$CERTS_DIR:/certs" \
        -w /certs \
        "$KEYTOOL_IMAGE" \
        keytool "$@"
}

# Pre-pull explícito de la imagen con feedback claro al usuario.
# Sin docker pull -q: si la red es lenta, el alumno necesita ver el progreso
# y NO debe haber timeouts que aborten la descarga.
echo -e "${CYAN}[generate-certs] Generando PKI para el Lab 12...${NC}"
echo "  [0/5] Verificando imagen $KEYTOOL_IMAGE..."
if docker image inspect "$KEYTOOL_IMAGE" > /dev/null 2>&1; then
    echo -e "${GREEN}    ✓ Imagen ya disponible localmente${NC}"
else
    echo -e "${YELLOW}    Descargando imagen (~440 MB, puede tardar 1-2 min en redes lentas)...${NC}"
    docker pull "$KEYTOOL_IMAGE"
    echo -e "${GREEN}    ✓ Imagen descargada${NC}"
fi

# 1. Crear CA root (openssl en host)
echo "  [1/5] Creando CA root..."
openssl req -new -x509 -keyout "$CERTS_DIR/ca.key" -out "$CERTS_DIR/ca.crt" \
    -days $DAYS -passout pass:$PASS \
    -subj "/CN=$CN_CA/OU=Lab12/O=NovaTech/L=Santiago/C=CL" 2>/dev/null

# 2. Truststore: contiene la CA root, lo usan tanto brokers como clients
echo "  [2/5] Creando truststore..."
run_keytool -keystore /certs/kafka.truststore.jks -alias CARoot \
    -import -file /certs/ca.crt \
    -storepass $PASS -keypass $PASS -noprompt > /dev/null 2>&1

# 3. Keystore por broker, firmado por la CA
for i in 1 2 3; do
    BROKER="kafka-broker-$i"
    echo "  [3/5] Generando keystore para $BROKER..."

    # Generar keypair (keytool en container)
    run_keytool -keystore /certs/$BROKER.keystore.jks -alias $BROKER \
        -genkey -keyalg RSA -storepass $PASS -keypass $PASS -validity $DAYS \
        -dname "CN=$BROKER, OU=Lab12, O=NovaTech, L=Santiago, C=CL" \
        -ext "SAN=DNS:$BROKER,DNS:localhost" > /dev/null 2>&1

    # Crear CSR (keytool en container)
    run_keytool -keystore /certs/$BROKER.keystore.jks -alias $BROKER \
        -certreq -file /certs/$BROKER.csr -storepass $PASS > /dev/null 2>&1

    # Firmar con la CA (openssl en host)
    openssl x509 -req -CA "$CERTS_DIR/ca.crt" -CAkey "$CERTS_DIR/ca.key" \
        -in "$CERTS_DIR/$BROKER.csr" -out "$CERTS_DIR/$BROKER.crt" \
        -days $DAYS -CAcreateserial -passin pass:$PASS \
        -extfile <(echo "subjectAltName=DNS:$BROKER,DNS:localhost") 2>/dev/null

    # Importar CA al keystore (keytool en container)
    run_keytool -keystore /certs/$BROKER.keystore.jks -alias CARoot \
        -import -file /certs/ca.crt \
        -storepass $PASS -keypass $PASS -noprompt > /dev/null 2>&1

    # Importar cert firmado al keystore (keytool en container)
    run_keytool -keystore /certs/$BROKER.keystore.jks -alias $BROKER \
        -import -file /certs/$BROKER.crt \
        -storepass $PASS -keypass $PASS -noprompt > /dev/null 2>&1
done

# 4. Crear archivo con la password (para que docker compose lo monte)
echo "  [4/5] Generando archivo credentials..."
echo "$PASS" > "$CERTS_DIR/cert-credentials"

# 5. Permisos restrictivos
echo "  [5/5] Aplicando permisos..."
chmod 600 "$CERTS_DIR"/*.key "$CERTS_DIR"/*.jks "$CERTS_DIR/cert-credentials" 2>/dev/null || true

echo -e "${GREEN}✓ Certificados generados en $CERTS_DIR${NC}"
echo -e "${GREEN}  Truststore: kafka.truststore.jks (lo usan TODOS)${NC}"
echo -e "${GREEN}  Keystores:  kafka-broker-{1,2,3}.keystore.jks (uno por broker)${NC}"
