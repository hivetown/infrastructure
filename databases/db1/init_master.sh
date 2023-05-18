#!/bin/bash
# Load env
set -a
. .env
set +a

gcloud compute instances network-interfaces update $PEER_INSTANCE_NAME --zone $PEER_INSTANCE_ZONE --aliases ""
gcloud compute instances network-interfaces update $INSTANCE_NAME --zone $INSTANCE_ZONE --aliases $ALIAS_IP

echo "A construir..."
source ./master/build.sh
echo "A correr..."
source ./master/run.sh

echo ""

sleep 3
echo "Estado do mysql-hivetown: "
docker ps -a

export STATE=MASTER
sudo /home/romul/keepalived/plug.sh
