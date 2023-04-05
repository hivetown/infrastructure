FROM mysql:latest

# Configuração do servidor MySQL mestre
ENV MYSQL_ROOT_PASSWORD=hello
ENV MYSQL_SERVER_ID=1
ENV MYSQL_LOG_BIN=mysql-bin
ENV MYSQL_BINLOG_DO_DB=hivetown

# Copia o arquivo my.cnf para o contêiner
COPY my.cnf /etc/mysql/conf.d/my.cnf

# Copia o arquivo init_replication.sql para o diretório de inicialização do MySQL
COPY create_replicator_user.sql /docker-entrypoint-initdb.d/

# Expõe a porta 3306
EXPOSE 3306
