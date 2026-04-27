## Настройка сервера frps с mTLS и дашбордом

### 1. Генерация сертификатов (mTLS)

Запустите скрипт генерации CA и сертификатов:

```bash
chmod +x gen_certs.sh
sudo ./gen_certs.sh
```

Скрипт создаст в `/opt/frp_certs/`:
- `ca.crt` / `ca.key` — корневой CA
- `frps.crt` / `frps.key` — сертификат сервера (для frps)
- `frpc.crt` / `frpc.key` — сертификат клиента (для frpc)

### 2. Настройка секретов

Создайте файл `.env`:

```bash
cat > .env << EOF
FRP_AUTH_TOKEN=<ваш_сложный_токен>
FRP_DASH_PASS=<пароль_для_дашборда>
EOF
```

### 3. Запуск сервера frps (mTLS + дашборд)

На сервере:

```bash
sudo ./frps.sh
```

Порты:
- **7000** — основной порт frp (mTLS)
- **7500** — дашборд (`http://<IP>:7500`, логин: `frp_admin`)
- **443** — HTTPS прокси
- **80** — HTTP прокси (опционально, закомментирован по умолчанию)

### 4. Настройка клиента frpc с mTLS

Скопируйте сертификаты на клиентскую машину в `/opt/frp_certs/`:
```
ca.crt      # общий CA для обеих сторон
frpc.crt    # сертификат клиента (сгенерирован на сервере)
frpc.key    # приватный ключ клиента
```

Запустите клиента:

```bash
sudo ./frpc_proxy.sh
```

### 5. Проверка mTLS

Проверьте цепочку доверия:
```bash
openssl verify -CAfile ca.crt frps.crt
openssl verify -CAfile ca.crt frpc.crt
```

Посмотрите информацию о сертификате:
```bash
openssl x509 -in frps.crt -text -noout
```

### 6. Дашборд

Доступ к дашборду: `http://<IP_сервера>:7500`
- Логин: `frp_admin`
- Пароль: из переменной `FRP_DASH_PASS`
