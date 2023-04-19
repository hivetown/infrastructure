FROM mysql:latest

# Configuração do servidor MySQL escravo
ENV MYSQL_ROOT_PASSWORD=hello
ENV MYSQL_SERVER_ID=2
ENV MYSQL_LOG_BIN=mysql-bin
ENV MYSQL_BINLOG_DO_DB=hivetown
ENV MYSQL_MASTER_HOST=10.164.0.12
ENV MYSQL_MASTER_PORT=3306
ENV MYSQL_MASTER_USER=replicator_hivetown
ENV MYSQL_MASTER_PASSWORD=hello2

# Copia o arquivo my.cnf para o contêiner
COPY my.cnf /etc/mysql/conf.d/my.cnf

# Copia o arquivo init_slave.sql para o diretório de inicialização do MySQL
COPY init_slave.sql /docker-entrypoint-initdb.d/

# Expõe a porta 3306
EXPOSE 3306
