FROM mysql:latest

# Configuração do servidor MySQL master
ENV MYSQL_ROOT_PASSWORD=hello
ENV MYSQL_SERVER_ID=1
ENV MYSQL_LOG_BIN=mysql-bin
ENV MYSQL_BINLOG_DO_DB=hivetown

# Copia o arquivo my.cnf para o container
COPY my.cnf /etc/mysql/conf.d/my.cnf

# Copia o arquivo init_master.sql para o diretório de inicialização do MySQL
COPY init_master.sql /docker-entrypoint-initdb.d/

# Expõe a porta 3306
EXPOSE 3306
