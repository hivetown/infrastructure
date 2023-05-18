#!/bin/bash
# Load env
set -a
. .env
set +a

backupDate=$(date +%Y-%m-%d_%H-%M-%S)

# Cria o nome do arquivo de backup com a data atual
BACKUP_FILENAME=${DATABASE}_$backupDate.sql

# Executa o mysqldump para fazer o backup dos bancos de dados no servidor master
mysqldump -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASSWORD $DATABASE > $BACKUP_DIR/$BACKUP_FILENAME

# Exibe uma mensagem de sucesso
echo "Backup concluído em $backupDate"