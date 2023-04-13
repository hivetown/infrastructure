# Processo de configuração

### Instalação do Docker
A instalação do Docker foi feito tanto no servidor master como no slave.

1. Listar os pacotes do sistema
```bash
$ sudo apt-get update
```

<br>

2. Instalar pacotes para permitir que o apt use um repositório via HTTPS
```bash
$ sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
```

<br>

3. Adicionar a chave GPG oficial do Docker
```bash
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

<br>

4. Adicionar o repositório do Docker às fontes do APT
```bash 
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```

<br>

5. Atualizar o banco de dados de pacotes
```bash
$ sudo apt-get update
```

<br>

6. Instalar a última versão do Docker
```bash
$ sudo apt-get install -y docker-ce docker-ce-cli containerd.io
```

<br>

Assim temos o Docker instalado no servidor master e no slave. Para confirmar a instalação, foi executado o comando abaixo:
```bash
$ docker --version
``` 

De seguida foi adicionado o usuário ao grupo docker para que não seja necessário executar o comando docker com o sudo.
```bash
$ sudo usermod -aG docker $USER
```

<br>


### Configuração da comunicação entre os servidores
Foi necessário configurar a comunicação no GCP criando uma regra de firewall para permitir a comunicação entre os servidores. Foi permetido o acesso aos portos 3306 e 33060 via TCP para o intervalo de IP 10.164.0.5 - slave e 10.164.0.6 - master.

### Foram criados os seguintes ficheiros para a configuração dos servidores

#### Master

1. [**Dockerfile**](./master/Dockerfile) - Ficheiro que contém as instruções para a criação da imagem do master
2. [**create_replicator_user.sql**](./master/create_replicator_user.sql) - Ficheiro que contém as instruções para a criação do utilizador uassdo na replicação.
3. [**my.cnf**](./master/my.cnf) - Ficheiro de configuração do MySQL

#### Slave
1. [**Dockerfile**](./slave/Dockerfile) - Ficheiro que contém as instruções para a criação da imagem do slave
2. [**init_slave.sql**](./slave/init_slave.sql) - Ficheiro que contém as instruções para a criação do slave (configuração e inicialização)
3. [**my.cnf**](./slave/my.cnf) - Ficheiro de configuração do MySQL

<br>

### Foram executados os seguintes comandos

#### No master

1. Criar a imagem do master
```bash
$ docker build -t mysql-master-image .
```

<br>

2. Criar o container do master
```bash
$ docker run --name mysql-master-hivetown -e MYSQL_ROOT_PASSWORD=hello -d -p 3306:3306 mysql-master-image
```

<br>

#### No slave

1. Criar a imagem do slave
```bash
$ docker build -t mysql-slave-image .
```

<br>

2. Criar o container do slave
```bash
$ docker run --name mysql-slave-hivetown -e MYSQL_ROOT_PASSWORD=hello -d -p 3306:3306 mysql-slave-image
```

<br>

#### Para testar a replicação
##### No master
1. Entrar no container do master
```bash
$ docker exec -it mysql-master-hivetown bash
```

<br>

2. Entrar no MySQL
```bash
$ mysql -u root -p
```

<br>

3. Criar a base de dados e a tabela
```sql
CREATE DATABASE hivetown;
USE hivetown;
CREATE TABLE users (id INT NOT NULL AUTO_INCREMENT, name VARCHAR(255) NOT NULL, PRIMARY KEY (id));
```

<br>

4. Inserir dados na tabela
```sql
INSERT INTO users (name) VALUES ('John');
INSERT INTO users (name) VALUES ('Mary');
INSERT INTO users (name) VALUES ('Peter');
```

<br>

##### No slave
1. Entrar no container do slave
```bash
$ docker exec -it mysql-slave-hivetown bash
```

<br>

2. Entrar no MySQL
```bash
$ mysql -u root -p
```

<br>

3. Verificar se os dados foram replicados
```sql
USE hivetown;
SELECT * FROM hivetown.users;
```

<br>

Também pode se verificar a replicação através do comando abaixo:
```bash
$ sudo docker exec -it mysql-slave-hivetown mysql -uroot -phello -e "SHOW SLAVE STATUS\G"
```
Em que deve verificar: 
- "Slave_IO_Running": yes - processo de leitura do binlog do servidor mestre para o servidor escravo está em execução
- "Slave_SQL_Running": yes - confirmar se processo de aplicação de atualizações está em execução

Se ambos os valores forem "Yes", a replicação está em execução e as atualizações estão a ser aplicadas com sucesso.

Tem outras colunas interessantes como:
- "Seconds_Behind_Master" - nunca deve estar a NULL. Se estiver, significa que o processo de replicação está parado. Se estiver a 0, significa que o processo de replicação está em execução e que o servidor escravo está a par do servidor mestre.
- "Last_IO_Error" - se tiver algum erro, deve ser verificado o que está a causar o problema.

<br>

#### Notas adicionais

Foram criados shell scripts para facilitar a execução dos comandos. Estes contêm os comandos necessários para:
1. [**Criar a imagem do master**](./master/build.sh)
2. [**Criar o container do master**](./master/run.sh)
3. [**Criar a imagem do slave**](./slave/build.sh)
4. [**Criar o container do slave**](./slave/run.sh)
5. [**Entrar no container do master**](./master/bash.sh)
6. [**Entrar no container do slave**](./slave/bash.sh)
7. [**Parar o container do master**](./master/stop.sh)
8. [**Parar o container do slave**](./slave/stop.sh)
9. [**Remover o container do master**](./master/remove.sh)
10. [**Remover o container do slave**](./slave/remove.sh)
11. [**Ver o status do container do slave**](./slave/status.sh)


<br>

## Servidor de backup

1. À semelhança do que foi feito no servidor master e no servidor slave, foram executados os pontos 1 a 6 do capítulo anterior para instalar o Docker no servidor de backup.

<br>

2. Criou-se um container com o mysql e o mysql-client para que seja possível executar o comando mysqldump para fazer o backup da base de dados.
```bash
$ docker run --name mysqldump-container -e MYSQL_ROOT_PASSWORD=hello -d -p 3306:3306 mysql
```

<br>

3. Foi criado um script responsável por fazer o backup da base de dados e armazenar numa pasta de backups. [**backup.sh**](./backup/backup.sh)

<br>

4. Foram concedidos privilégios de execução ao script.
```bash
$ chmod u+x backup.sh
```

<br>

5. Por fim foi configurada a automatização do backup através do crontab, em que o script vai ser executado todos os dias às 2 da manhã (hora de suposta pouca atividade no servidor).
```bash
$ crontab -e
```
e adicionou-se a seguinte linha:
```bash
0 2 * * * ~/backup.sh
```

<br>

