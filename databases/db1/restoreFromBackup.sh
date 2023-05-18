#!/bin/bash

# Defina as variáveis para a conexão SSH
USER="romul"
HOST="10.0.112.2"
BACKUP_DIR="/home/romul/backups"

# Defina as variáveis para o SCP
DEST="/home/romul/"

# Conecte à máquina de backup e liste todos os arquivos de backup
LATEST_FILE=$(ssh ${USER}@${HOST} "ls -t ${BACKUP_DIR}/*.sql | head -n 1")

# Verifique se foi encontrado um arquivo de backup válido
if [ -n "${LATEST_FILE}" ]; then
    # Extrai o nome do arquivo mais recente
    FILENAME=$(basename ${LATEST_FILE})

    # Transfere o arquivo mais recente via SCP para o diretório de destino
    scp ${USER}@${HOST}:${LATEST_FILE} ${DEST}/${FILENAME}

    echo "Arquivo ${FILENAME} transferido com sucesso para ${DEST}"
else
    echo "Nenhum arquivo de backup encontrado em ${BACKUP_DIR}"
fi

# Adiciona o comando USE hivetown antes do comando DROP TABLE
sed -i '1iUSE hivetown;' ${DEST}/${FILENAME}

docker exec -i mysql-db-1 mysql -uroot -phello -e "CREATE DATABASE hivetown;"
docker exec -i mysql-db-1 mysql -uroot -phello hivetown < ${DEST}/${FILENAME};

# Elimina o ficheiro sql
rm ${DEST}/${FILENAME}

echo "Backup feito com sucesso!"
