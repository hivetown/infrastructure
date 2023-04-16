#!/bin/bash

echo "A construir..."
source ./slave/build.sh
echo "A correr..."
source ./slave/run.sh

echo ""

sleep 3
echo "Estado do mysql-db-2: "
docker ps -a
