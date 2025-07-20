#!/bin/bash

docker run -d --restart always --name frpc \
    -p 7000:7000 \
    -e FRP_AUTH_TOKEN \
    -e FRP_SERVER_ADDR \
    -v ./frpc_pve.toml:/etc/frpc.toml \
    ghcr.io/fatedier/frpc:v0.63.0 -c /etc/frpc.toml