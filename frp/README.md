## Настройка сервера frps

1. Зайти на сервер, создать ssh ключи, закинуть публичный ключ в гитхаб
2. Секреты лежат в .env( FRP_AUTH_TOKEN= FRP_DASH_PASS=)
3. Запустить на сервере:

```bash
sudo wget -qO- https://gist.githubusercontent.com/NikolayEremenko/1112079ab282fe2dc493a01ef3b74afa/raw/64f27d39fb6a8200df87b87b091b779209af8667/run_frp.sh | FRP_AUTH_TOKEN="" FRP_DASH_PASS="" FRP_ROLE='frps' bash
``` 


## Настройка клиента frp

```bash
sudo wget -qO- https://gist.githubusercontent.com/NikolayEremenko/1112079ab282fe2dc493a01ef3b74afa/raw/64f27d39fb6a8200df87b87b091b779209af8667/run_frp.sh | FRP_SERVER_ADDR="" FRP_AUTH_TOKEN="" FRP_ROLE='frpc_proxy' INGRESS_IP="192.168.1.2" bash
```

## Создание сертификатов для сервера

* Создаем my-openssl.cnf
```
cat > my-openssl.cnf << EOF
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
```

* CA certificates:
```bash
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -subj "/CN=FRP_Root_CA" -days 5000 -out ca.crt
```

* frp certificates:
```
openssl genrsa -out cert.key 2048

openssl req -new -sha256 -key cert.key \
    -subj "/CN=client-server-cert" \
    -config my-openssl.cnf \
    -out cert.csr

openssl x509 -req -days 365 -sha256 \
	-in cert.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
	-extfile my-openssl.cnf \
	-out cert.crt
```

* Смотрим информацию о сертификате
```bash
openssl x509 -in cert.crt -text -noout
```

* Проверяем цепочку доверия
```bash
openssl verify -CAfile ca.crt cert.crt
```