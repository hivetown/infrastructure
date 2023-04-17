#!/bin/bash

# Define o nome do container
container_name="mysql-db-1"

# Verifica o status do container
status=$(docker inspect -f '{{.State.Status}}' $container_name)

# Obtém o nome da imagem do contêiner
image=$(docker inspect -f '{{.Config.Image}}' $container_name)

# Verifica se o container foi encerrado ou não
if [ "$status" == "exited" ]; then
    if [ "$image" == "mysql-master-image" ]; then
       echo "A INICIAR O SLAVE!"

       # Mudança da configuração do keepalived
       cp /home/romul/keepalived/keepalivedSLAVE.conf /home/romul/keepalived/keepalived.conf
       sudo cp -R /home/romul/keepalived/keepalived.conf /etc/keepalived/
       sudo systemctl start keepalived
       
       # Mudança da configuração do mysql para slave
       source /home/romul/newSlave.sh
    else
        echo "A REINICIAR O SLAVE"
        docker restart $container_name
    fi
else
    echo "O container está em execução."
fi
