CHANGE MASTER TO
    MASTER_HOST='${MYSQL_MASTER_HOST}',
    MASTER_USER='${MYSQL_MASTER_USER}',
    MASTER_PASSWORD='${MYSQL_MASTER_PASSWORD}',
    MASTER_PORT=3306,
    MASTER_LOG_FILE='mysql-bin.000001',
    MASTER_LOG_POS=0;
START SLAVE;