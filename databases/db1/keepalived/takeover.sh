#!/bin/bash
# Load env
set -a
. .env
set +a

# Define o nome do container
container_name="mysql-hivetown"

if docker ps -a | grep -q $container_name; then

    # Obtém o nome da imagem do contêiner
    image=$(docker inspect -f '{{.Config.Image}}' $container_name)

    if [ "$image" == "mysql-master-image" ]; then
        echo "É MASTER"
    else
        state=$(grep "^ *state" /etc/keepalived/keepalived.conf | awk '{print $2}')
        if [ "$state" = "BACKUP" ]; then
            echo "A INICIAR O MASTER!"

            gcloud compute instances network-interfaces update $PEER_INSTANCE_NAME --zone $PEER_INSTANCE_ZONE --aliases "" >> /home/romul/log.txt 2>&1
            gcloud compute instances network-interfaces update $INSTANCE_NAME --zone $INSTANCE_ZONE --aliases $ALIAS_IP
       
            # Mudança da configuração do keepalived
            sudo cp /home/romul/keepalived/keepalived.master.conf /etc/keepalived/keepalived.conf
            sudo systemctl restart keepalived
        fi
        
        # Mudança da configuração do mysql para master
        source /home/romul/newMaster.sh
    fi
fi

