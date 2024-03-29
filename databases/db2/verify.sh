#!/bin/bash

# Define o nome do container
container_name="mysql-hivetown"

# Verifica o status do container
status=$(docker inspect -f '{{.State.Status}}' $container_name)

# Obtém o nome da imagem do contêiner
image=$(docker inspect -f '{{.Config.Image}}' $container_name)

# Verifica se o container foi encerrado ou não
if [ "$status" == "exited" ]; then
    if [ "$image" == "mysql-master-image" ]; then
        state=$(grep "^ *state" /etc/keepalived/keepalived.conf | awk '{print $2}')
        if [ "$state" = "MASTER" ]; then
            echo "A INICIAR O SLAVE!"

            # Mudança da configuração do keepalived
            export STATE=BACKUP
        fi
        # Mudança da configuração do mysql para slave
        source /home/romul/newSlave.sh

    else
        echo "A REINICIAR O SLAVE"
        docker restart $container_name
    fi
else
echo "O container está em execução."
fi
