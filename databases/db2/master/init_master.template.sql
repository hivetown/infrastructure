CREATE USER '${MYSQL_REPLICATOR_USER}'@'%' IDENTIFIED WITH mysql_native_password BY '${MYSQL_REPLICATOR_PASSWORD}'; -- Cria um user para funcionar como replica
GRANT REPLICATION SLAVE ON *.* TO '${MYSQL_REPLICATOR_USER}'@'%'; -- Concede privilégios de replicação ao user
FLUSH PRIVILEGES; -- Recarrrega as tabelas de privilégios

CREATE USER '${MYSQL_BACKUP_USER}'@'%' IDENTIFIED WITH mysql_native_password BY '${MYSQL_BACKUP_PASSWORD}'; -- Cria um user para funcionar como backup
GRANT ALL PRIVILEGES ON hivetown.* TO '${MYSQL_BACKUP_USER}'@'%';
GRANT PROCESS ON *.* TO '${MYSQL_BACKUP_USER}'@'%';
FLUSH PRIVILEGES; -- Recarrega as tabelas de privilégios
