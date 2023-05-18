#!/bin/bash

# Choose which keepalived.conf to copy
toCopy="keepalived.backup.conf"
if docker ps -a | grep -q $container_name; then

    # Obtém o nome da imagem do contêiner
    image=$(docker inspect -f '{{.Config.Image}}' $container_name)

    if [ "$image" == "mysql-master-image" ]; then
        toCopy="keepalived.master.conf"
    fi
fi

# Copy needed files to /etc/keepalived
sudo cp $toCopy /etc/keepalived/keepalived.conf
sudo cp .env /etc/keepalived/.env
sudo cp takeover.sh /etc/keepalived/takeover.sh

# Restart keepalived
sudo systemctl restart keepalived
