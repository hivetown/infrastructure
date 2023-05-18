#!/bin/bash
# Check if keepalived.conf exists
if [ ! -f keepalived.conf ]; then
    echo "keepalived.conf not found! Compute it from template first."
    exit 1
fi

cp keepalived.conf /etc/keepalived
# .env is necessary for takeover.sh
cp .env /etc/keepalived
cp takeover.sh /etc/keepalived

systemctl restart keepalived
