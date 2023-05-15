#!/bin/bash

# Define o nome do container
container_name="mysql-db-2"

if docker ps -a | grep -q $container_name; then

    # Obtém o nome da imagem do contêiner
    image=$(docker inspect -f '{{.Config.Image}}' $container_name)

    if [ "$image" == "mysql-master-image" ]; then
        echo "É MASTER"
    else
        state=$(grep "^ *state" /etc/keepalived/keepalived.conf | awk '{print $2}')
        if [ "$state" = "BACKUP" ]; then
            echo "A INICIAR O MASTER!"

            gcloud compute instances network-interfaces update vm-database-1 --zone europe-west4-a --aliases ""
            gcloud compute instances network-interfaces update vm-database-2 --zone europe-west4-b --aliases 10.0.128.10

       
            # Mudança da configuração do keepalived
            cp /home/romul/keepalived/keepalivedMASTER.conf /home/romul/keepalived/keepalived.conf
            sudo cp -R /home/romul/keepalived/keepalived.conf /etc/keepalived/
            sudo systemctl restart keepalived
        fi
        # Mudança da configuração do mysql para master
        source /home/romul/newMaster.sh
    fi
fi

