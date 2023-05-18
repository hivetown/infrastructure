#!/bin/bash

# Define as variáveis de ambiente necessárias para o backup
MYSQL_USER=mybackupuser
MYSQL_PASSWORD=mybackuppassword
DATABASE=hivetown
BACKUP_DIR=backups
MYSQL_HOST=10.164.0.6
MYSQL_PORT=3306



# Cria o nome do arquivo de backup com a data atual
BACKUP_FILENAME=${DATABASE}_$(date +%Y-%m-%d_%H-%M-%S).sql

# Executa o mysqldump para fazer o backup dos bancos de dados no servidor master
mysqldump -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASSWORD $DATABASE  > $BACKUP_DIR/$BACKUP_FILENAME

# Exibe uma mensagem de sucesso
echo "Backup concluído em $(date +%Y-%m-%d_%H:%M:%S)"
