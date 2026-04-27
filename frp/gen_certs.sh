#!/bin/bash
# Генерация CA и сертификатов для mTLS frp
set -euo pipefail

CERT_DIR="/opt/frp_certs"
mkdir -p "$CERT_DIR"

cd "$CERT_DIR"

# Создаем конфигурационный файл OpenSSL
cat > my-openssl.cnf << 'EOF'
[ ca ]
default_ca = CA_default

[ CA_default ]
x509_extensions = usr_cert

[ req ]
default_bits        = 2048
default_md          = sha256
default_keyfile     = privkey.pem
distinguished_name  = req_distinguished_name
attributes          = req_attributes
x509_extensions     = v3_ca
string_mask         = utf8only

[ req_distinguished_name ]
[ req_attributes ]

[ usr_cert ]
basicConstraints       = CA:FALSE
nsComment              = "OpenSSL Generated Certificate"
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
keyUsage               = digitalSignature, keyEncipherment
extendedKeyUsage       = serverAuth, clientAuth

[ v3_ca ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = CA:true
keyUsage               = digitalSignature, keyEncipherment, keyCertSign
EOF

# Генерация CA
if [ ! -f ca.crt ]; then
    echo "=== Generating CA ==="
    openssl genrsa -out ca.key 2048
    openssl req -x509 -new -nodes -key ca.key \
        -subj "/CN=FRP_Root_CA" \
        -days 5000 -out ca.crt
    echo "CA created: ca.crt, ca.key"
else
    echo "CA already exists, skipping."
fi

# Генерация сертификата для сервера (frps)
if [ ! -f frps.crt ]; then
    echo "=== Generating server certificate ==="
    openssl genrsa -out frps.key 2048
    openssl req -new -sha256 -key frps.key \
        -subj "/CN=frps-server-cert" \
        -config my-openssl.cnf \
        -out frps.csr

    cat > server_ext.cnf << 'EOF'
basicConstraints       = CA:FALSE
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
keyUsage               = digitalSignature, keyEncipherment
extendedKeyUsage       = serverAuth, clientAuth
subjectAltName         = @alt_names

[ alt_names ]
DNS.1 = localhost
IP.1  = 127.0.0.1
EOF

    openssl x509 -req -days 3650 -sha256 \
        -in frps.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
        -extfile server_ext.cnf \
        -out frps.crt
    rm -f frps.csr server_ext.cnf
    echo "Server cert created: frps.crt, frps.key"
else
    echo "Server certificate already exists, skipping."
fi

# Генерация сертификата для клиента (frpc)
if [ ! -f frpc.crt ]; then
    echo "=== Generating client certificate ==="
    openssl genrsa -out frpc.key 2048
    openssl req -new -sha256 -key frpc.key \
        -subj "/CN=frpc-client-cert" \
        -config my-openssl.cnf \
        -out frpc.csr

    cat > client_ext.cnf << 'EOF'
basicConstraints       = CA:FALSE
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
keyUsage               = digitalSignature, keyEncipherment
extendedKeyUsage       = serverAuth, clientAuth
EOF

    openssl x509 -req -days 3650 -sha256 \
        -in frpc.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
        -extfile client_ext.cnf \
        -out frpc.crt
    rm -f frpc.csr client_ext.cnf
    echo "Client cert created: frpc.crt, frpc.key"
else
    echo "Client certificate already exists, skipping."
fi

# Проверка цепочки доверия
echo ""
echo "=== Verification ==="
openssl verify -CAfile ca.crt frps.crt && echo "frps cert OK" || echo "frps cert FAILED"
openssl verify -CAfile ca.crt frpc.crt && echo "frpc cert OK" || echo "frpc cert FAILED"

# Показать информацию о сертификатах
echo ""
echo "=== Server Certificate Info ==="
openssl x509 -in frps.crt -subject -dates -noout
echo ""
echo "=== Client Certificate Info ==="
openssl x509 -in frpc.crt -subject -dates -noout

echo ""
echo "=== Files in $CERT_DIR ==="
ls -la "$CERT_DIR"/frp*.crt "$CERT_DIR"/frp*.key "$CERT_DIR"/ca.* 2>/dev/null
