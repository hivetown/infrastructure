#!/bin/bash
# Load env
set -a
. .env
set +a

# Conecte à máquina de backup e liste todos os arquivos de backup
LATEST_FILE=$(ssh ${BACKUP_USER}@${BACKUP_IP} "ls -t ${BACKUP_DIR}/*.sql | head -n 1")

# Verifique se foi encontrado um arquivo de backup válido
if [ -n "${LATEST_FILE}" ]; then
    # Extrai o nome do arquivo mais recente
    FILENAME=$(basename ${LATEST_FILE})

    # Transfere o arquivo mais recente via SCP para o diretório de destino
    scp ${BACKUP_USER}@${BACKUP_IP}:${LATEST_FILE} ${BACKUP_DESTINATION}/${FILENAME}

    echo "Arquivo ${FILENAME} transferido com sucesso para ${BACKUP_DESTINATION}"
else
    echo "Nenhum arquivo de backup encontrado em ${BACKUP_DIR}"
fi

# Adiciona o comando USE hivetown antes do comando DROP TABLE
sed -i '1iUSE hivetown;' ${BACKUP_DESTINATION}/${FILENAME}

docker exec -i mysql-hivetown mysql -e "CREATE DATABASE hivetown;"
docker exec -i mysql-hivetown mysql hivetown < ${BACKUP_DESTINATION}/${FILENAME};

# Elimina o ficheiro sql
rm ${BACKUP_DESTINATION}/${FILENAME}

echo "Backup feito com sucesso!"
