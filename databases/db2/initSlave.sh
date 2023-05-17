#!/bin/bash

echo "A construir..."
source ./slave/build.sh
echo "A correr..."
source ./slave/run.sh

echo ""

sleep 3
echo "Estado do mysql-db-2: "
docker ps -a

cp /home/romul/keepalived/keepalivedSLAVE.conf /etc/keepalived/keepalived.conf &&
sudo cp -R /home/romul/keepalived/takeover.sh /etc/keepalived/ &&
sudo systemctl restart keepalived
