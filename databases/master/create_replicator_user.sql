CREATE USER 'replicator_hivetown'@'%' IDENTIFIED WITH mysql_native_password BY 'hello2';
GRANT REPLICATION SLAVE ON *.* TO 'replicator_hivetown'@'%';
FLUSH PRIVILEGES;
