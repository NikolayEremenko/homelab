#!/bin/bash

docker run -d --restart always --name frps \
    -p 7000:7000 \
    -p 7500:7500 \
    -p 80:80 \
    -p 443:443 \
    -p 2233:2233 \
    -e FRP_AUTH_TOKEN \
    -e FRP_DASH_PASS \
    -v ./frps.toml:/etc/frps.toml \
    ghcr.io/fatedier/frps:v0.63.0 -c /etc/frps.toml