CHANGE MASTER TO
    MASTER_HOST='10.164.0.13',
    MASTER_USER='replicator_hivetown',
    MASTER_PASSWORD='hello2',
    MASTER_PORT=3306,
    MASTER_LOG_FILE='mysql-bin.000001',
    MASTER_LOG_POS=0;
START SLAVE;