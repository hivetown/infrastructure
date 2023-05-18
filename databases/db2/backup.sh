#!/bin/bash
# Load env
set -a
. /home/romul/.env
set +a

# Executa o mysqldump para fazer o backup dos bancos de dados no servidor master
docker exec mysql-hivetown mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD $DATABASE  > MasterDown.sql

# Define o nome do arquivo SQL
sql_file="MasterDown.sql"

# Adiciona o comando USE hivetown antes do comando DROP TABLE
sed -i '1iUSE hivetown;' $sql_file

# Exibe uma mensagem de sucesso
echo "Backup concluído em $(date +%Y-%m-%d_%H:%M:%S)"
