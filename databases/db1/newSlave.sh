#!/bin/bash

echo "A iniciar a mudança para slave..."

# Para e remove o conteiner que está como master
source /home/romul/stop.sh
source /home/romul/remove.sh

echo "Master parado e eliminado"

echo "A construir..."
source /home/romul/slave/build.sh
echo "A correr..."
source /home/romul/slave/run.sh

echo ""

sleep 3
echo "Estado do mysql-db-1: "
docker ps -a

echo ""

echo "Slave pronto a usar!"