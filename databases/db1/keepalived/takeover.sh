#!/bin/bash

# Define o nome do container
container_name="mysql-db-1"

# Obtém o nome da imagem do contêiner
image=$(docker inspect -f '{{.Config.Image}}' $container_name)

# Verifica se o container foi encerrado ou não

if [ "$image" == "mysql-master-image" ]; then
    echo "É MASTER"
else
    echo "A INICIAR O MASTER!"

    gcloud compute instances network-interfaces update vm-database-2 --zone europe-west4-b --aliases ""
    gcloud compute instances network-interfaces update vm-database-1 --zone europe-west4-a --aliases 10.164.0.12

    # Mudança da configuração do keepalived
    cp /home/romul/keepalived/keepalivedMASTER.conf /home/romul/keepalived/keepalived.conf
    sudo cp -R /home/romul/keepalived/keepalived.conf /etc/keepalived/
    sudo systemctl restart keepalived

    if systemctl status keepalived | grep -q 'MASTER'; then
        # Mudança da configuração do mysql para master
        source /home/romul/newMaster.sh
    fi

fi

