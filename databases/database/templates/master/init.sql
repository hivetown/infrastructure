CREATE USER '${REPLICATOR_USER_USERNAME}'@'%' IDENTIFIED WITH mysql_native_password BY ${REPLICATOR_USER_PASSWORD}; -- Cria um user para funcionar como replica
GRANT REPLICATION SLAVE ON *.* TO '${REPLICATOR_USER_USERNAME}'@'%'; -- Concede privilégios de replicação ao user
FLUSH PRIVILEGES; -- Recarrega as tabelas de privilégios

CREATE USER '${BACKUP_USER_USERNAME}'@'%' IDENTIFIED WITH mysql_native_password BY '${BACKUP_USER_PASSWORD}'; -- Cria um user para funcionar como backup
GRANT ALL PRIVILEGES ON hivetown.* TO '${BACKUP_USER_USERNAME}'@'%';
GRANT PROCESS ON *.* TO '${BACKUP_USER_USERNAME}'@'%';
FLUSH PRIVILEGES; -- Recarrega as tabelas de privilégios
