FROM mysql:latest

# Copia o arquivo my.cnf para o contêiner
COPY my.cnf /etc/mysql/conf.d/my.cnf

# Copia o arquivo init_slave.sql para o diretório de inicialização do MySQL
COPY init_slave.sql /docker-entrypoint-initdb.d/

# Expõe a porta 3306
EXPOSE 3306
