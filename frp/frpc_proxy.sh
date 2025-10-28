#!/bin/bash

docker run -d --restart always --name frpc \
    -p 7000:7000 \
    -e FRP_AUTH_TOKEN \
    -e FRP_SERVER_ADDR \
    -e INGRESS_IP \
    -v ./frpc_proxy.toml:/etc/frpc.toml \
    -v /opt/frp_certs/:/opt/frp_certs \
    ghcr.io/fatedier/frpc:v0.63.0 -c /etc/frpc.toml