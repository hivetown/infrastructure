#!/bin/bash

echo "A iniciar a mudança para master..."

# Faz o backup
source /home/romul/backup.sh

echo "Backup efetuado com sucesso!"

# Para e remove o conteiner do slave
source /home/romul/stop.sh
source /home/romul/remove.sh

echo "Slave parado e eliminado"

# Faz build e run do novo master
source /home/romul/master/build.sh
source /home/romul/master/run.sh

echo "Master construído e a correr..."
echo "Aguardar 5 segundos para atualizar a base de dados com o último backup..."

sleep 5

# Executa o ficheiro sql para atualizar o master
while ! docker exec -i mysql-db-1 mysql -uroot -phello -e "CREATE DATABASE hivetown;"; do
  sleep 2
  echo "A tentar novamente..."
done
docker exec -i mysql-db-1 mysql -uroot -phello hivetown < MasterDown.sql;



# Elimina o ficheiro sql
rm MasterDown.sql

echo "Master pronto a usar!"
