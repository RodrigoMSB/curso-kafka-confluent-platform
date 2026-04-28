#!/bin/bash
# Genera CA + certificados de servidor para los 3 brokers Kafka.
# Usado para TLS en listener cliente (SASL_SSL://).

set -euo pipefail
source "$(dirname "$0")/common.sh"

CERTS_DIR="$(dirname "$0")/../infra/certs"
PASS="${TLS_KEYSTORE_PASSWORD:-changeit}"
DAYS=3650
CN_CA="NovaTech-CA-Lab12"

mkdir -p "$CERTS_DIR"

# Idempotencia: si ya existen, salir
if [[ -f "$CERTS_DIR/ca.crt" ]]; then
    echo -e "${YELLOW}Los certificados ya existen en $CERTS_DIR. Saltando generación.${NC}"
    echo -e "${YELLOW}Para regenerar: borrar el directorio infra/certs/ y volver a ejecutar.${NC}"
    exit 0
fi

echo -e "${CYAN}[generate-certs] Generando PKI para el Lab 12...${NC}"

# 1. Crear CA root
echo "  [1/5] Creando CA root..."
openssl req -new -x509 -keyout "$CERTS_DIR/ca.key" -out "$CERTS_DIR/ca.crt" \
    -days $DAYS -passout pass:$PASS \
    -subj "/CN=$CN_CA/OU=Lab12/O=NovaTech/L=Santiago/C=CL" 2>/dev/null

# 2. Truststore: contiene la CA root, lo usan tanto brokers como clients
echo "  [2/5] Creando truststore..."
keytool -keystore "$CERTS_DIR/kafka.truststore.jks" -alias CARoot \
    -import -file "$CERTS_DIR/ca.crt" \
    -storepass $PASS -keypass $PASS -noprompt 2>/dev/null

# 3. Keystore por broker, firmado por la CA
for i in 1 2 3; do
    BROKER="kafka-broker-$i"
    echo "  [3/5] Generando keystore para $BROKER..."

    # Generar keypair
    keytool -keystore "$CERTS_DIR/$BROKER.keystore.jks" -alias $BROKER \
        -genkey -keyalg RSA -storepass $PASS -keypass $PASS -validity $DAYS \
        -dname "CN=$BROKER, OU=Lab12, O=NovaTech, L=Santiago, C=CL" \
        -ext "SAN=DNS:$BROKER,DNS:localhost" 2>/dev/null

    # Crear CSR
    keytool -keystore "$CERTS_DIR/$BROKER.keystore.jks" -alias $BROKER \
        -certreq -file "$CERTS_DIR/$BROKER.csr" -storepass $PASS 2>/dev/null

    # Firmar con la CA
    openssl x509 -req -CA "$CERTS_DIR/ca.crt" -CAkey "$CERTS_DIR/ca.key" \
        -in "$CERTS_DIR/$BROKER.csr" -out "$CERTS_DIR/$BROKER.crt" \
        -days $DAYS -CAcreateserial -passin pass:$PASS \
        -extfile <(echo "subjectAltName=DNS:$BROKER,DNS:localhost") 2>/dev/null

    # Importar CA al keystore
    keytool -keystore "$CERTS_DIR/$BROKER.keystore.jks" -alias CARoot \
        -import -file "$CERTS_DIR/ca.crt" \
        -storepass $PASS -keypass $PASS -noprompt 2>/dev/null

    # Importar cert firmado al keystore
    keytool -keystore "$CERTS_DIR/$BROKER.keystore.jks" -alias $BROKER \
        -import -file "$CERTS_DIR/$BROKER.crt" \
        -storepass $PASS -keypass $PASS -noprompt 2>/dev/null
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
