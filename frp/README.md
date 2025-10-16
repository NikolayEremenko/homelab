## Настройка сервера frps

1. Зайти на сервер, создать ssh ключи, закинуть публичный ключ в гитхаб
2. Секреты лежат в .env( FRP_AUTH_TOKEN= FRP_DASH_PASS=)
3. Запустить на сервере:

```bash
sudo wget -qO- https://gist.githubusercontent.com/NikolayEremenko/c344e0c5c3fafb6b0c81a06991df9e52/raw/eb3b673dcad85f5f1ebf76023cdebe52583b8afa/run_frps.sh | FRP_AUTH_TOKEN='' FRP_DASH_PASS='' bash
```