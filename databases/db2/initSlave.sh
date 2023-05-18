#!/bin/bash

echo "A construir..."
source ./slave/build.sh
echo "A correr..."
source ./slave/run.sh

echo ""

sleep 3
echo "Estado do mysql-hivetown: "
docker ps -a

sudo bash /home/romul/keepalived/plug.sh
