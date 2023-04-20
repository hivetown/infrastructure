#!/bin/bash

gcloud compute instances network-interfaces update vm-database-2 --zone europe-west4-b --aliases ""
gcloud compute instances network-interfaces update vm-database-1 --zone europe-west4-a --aliases 10.164.0.12

echo "A construir..."
source ./master/build.sh
echo "A correr..."
source ./master/run.sh

echo ""

sleep 3
echo "Estado do mysql-db-1: "
docker ps -a

cp /home/romul/keepalived/keepalivedMASTER.conf /home/romul/keepalived/keepalived.conf &&
sudo cp -R /home/romul/keepalived/keepalived.conf /etc/keepalived/ &&
sudo cp -R /home/romul/keepalived/takeover.sh /etc/keepalived/ &&
sudo systemctl restart keepalived
