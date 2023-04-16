#!/bin/bash

# Define o nome do container
container_name="mysql-db-2"

# Obtém o nome da imagem do contêiner
image=$(docker inspect -f '{{.Config.Image}}' $container_name)

# Verifica se o container foi encerrado ou não

if [ "$image" == "mysql-master-image" ]; then
    echo "É MASTER"
else
    echo "A INICIAR O MASTER!"

    # Mudança da configuração do keepalived
    cp /home/romul/keepalived/keepalivedMASTER.conf /home/romul/keepalived/keepalived.conf
    sudo cp -R /home/romul/keepalived/keepalived.conf /etc/keepalived/
    sudo systemctl restart keepalived
    
    # Mudança da configuração do mysql para master
    source /home/romul/newMaster.sh
fi

