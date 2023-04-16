#!/bin/bash

echo "A iniciar a mudança para slave..."

# Para e remove o conteiner que está como master
source ./stop.sh
source ./remove.sh

echo "Master parado e eliminado"

echo "A construir..."
source ./slave/build.sh
echo "A correr..."
source ./slave/run.sh

echo ""

sleep 3
echo "Estado do mysql-db-2: "
docker ps -a

echo ""

echo "Slave pronto a usar!"