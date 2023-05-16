FROM mysql:8.0.4

# Copia o arquivo mysql.cnf para o container
COPY mysql.cnf /etc/mysql/conf.d/my.cnf

# Copia o arquivo init.sql para o diretório de inicialização do MySQL
COPY init.sql /docker-entrypoint-initdb.d/

# Expõe a porta 3306
EXPOSE 3306
