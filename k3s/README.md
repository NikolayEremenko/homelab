# Домашний тестовый k3s кластер

# Установка k3s

## Master
```bash
curl -sfL https://get.k3s.io | K3S_TOKEN=${k3s_cluster_token} sh -s
```

## Worker
```bash
curl -sfL https://get.k3s.io | K3S_URL=https://${k3s_server_address}:6443 K3S_TOKEN=${k3s_cluster_token} sh -s - agent
```

# Основные приложения

## CertManager

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.19.1/cert-manager.yaml
```

```bash
source ../.env && envsubst < 00-certmanager.yaml | kubectl apply -f -
```

## Argo CD

```bash
kubectl apply -f 01-argocd.yaml
```