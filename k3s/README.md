# Домашний тестовый k3s кластер

Под капотом:
Mini PC: Beelink - AMD Ryzen 7 6800U 8CPU/24RAM

Proxmox кластер с виртуалками под k3s

Nodes - cpu/mem

Master - 2/4
Worker - 4/8

# Основные приложения

## CertManager

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.19.1/cert-manager.yaml
```

```bash
source ../../.env && envsubst < 00-certmanager.yaml | kubectl apply -f -
```

## Argo CD

```bash
kubectl apply -f 01-argocd.yaml
```