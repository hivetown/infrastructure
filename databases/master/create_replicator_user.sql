CREATE USER 'replicator_hivetown'@'%' IDENTIFIED WITH mysql_native_password BY 'hello2'; -- Cria um user para funcionar como replica
GRANT REPLICATION SLAVE ON *.* TO 'replicator_hivetown'@'%'; -- Concede privilégios de replicação ao user
FLUSH PRIVILEGES; -- Recarrrega as tabelas de privilégios
