#!/bin/bash

echo "A construir..."
source ./master/build.sh
echo "A correr..."
source ./master/run.sh

echo ""

sleep 3
echo "Estado do mysql-db-1: "
docker ps -a
