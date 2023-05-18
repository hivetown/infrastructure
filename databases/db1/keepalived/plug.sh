#!/bin/bash

# Choose which keepalived.conf to copy
toCopy="keepalived.backup.conf"
if [ "$STATE" == "MASTER" ]; then
  toCopy="keepalived.master.conf"
fi

# Copy needed files to /etc/keepalived
sudo cp $toCopy /etc/keepalived/keepalived.conf
sudo cp .env /etc/keepalived/.env
sudo cp takeover.sh /etc/keepalived/takeover.sh

# Restart keepalived
sudo systemctl restart keepalived
