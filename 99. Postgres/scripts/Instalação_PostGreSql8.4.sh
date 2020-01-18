# Instalação do Client.

yum install postgresql.x86_64

#Instalação do repositório.

rpm -Uvh http://yum.pgrpms.org/reporpms/8.4/pgdg-centos-8.4-2.noarch.rpm

#Instalação do Pacote.(Marque "Y" para aceitar que os pacotes sejam instalados).

yum install postgresql84-server.x86_64

#Start do PostgreSQL (Banco)

/etc/init.d/postgresql-8.4 initdb

#Start do PostgreSQL (Serviço)

/etc/init.d/postgresql-8.4 start

#Liberando o acesso do postgresql para logon externo.

cd /var/lib/pgsql/8.4/data

# Descobrindo o runlevel de inicialização da máquina. 

head -n 30 /etc/inittab |  grep :initdefault | cut -c 4

# Depedendo do número que aparecer acima.

cd /etc/rc$x.d

# Mude o processo de K -> S

mv K36postgresql-8.4 S36postgresql-8.4

# Faça um shutdown na máquina

shutdown -r now

# Verifique se o processo do PostGreSql subiu.

ps faxu | grep postgresql

#####AGREGAR PROCEDIMENTO DE LIBERAÇÃO DE ACESSO###################

##AQUI COMECA OS PASSOS SQL - BASE WIN1252 EM POSTGRESQL LINUX (CentOS).

-- Altera a senha do usuário postgres do database.

ALTER USER postgres WITH ENCRYPTED PASSWORD 'senha'

--Altera as variaveis LC_CTYPE e LC_COLLATE 

ALTER DATABASE template0 SET LC_CTYPE TO 'C'
ALTER DATABASE template0 SET LC_COLLATE TO 'C';

-- Cria uma base de dados a qual se transformará em template

CREATE DATABASE template0b TEMPLATE template0 LC_COLLATE 'C' LC_CTYPE 'C';

-- Seta para false o argumento que diz que o template0 é template padrão.

UPDATE pg_database SET datistemplate = false WHERE datname = 'template0';

-- Com o update acima , vocÊ conseguirá dropar o template0.

DROP DATABASE template0;

-- Renomeia o database para template0

ALTER DATABASE template0b RENAME TO template0;

-- Seta novamente o novo template0 como template padrão.

UPDATE pg_database SET datistemplate = true WHERE datname = 'template0';

-- Cria o database origem.

CREATE DATABASE agromanager TEMPLATE template0 OWNER agrom ENCODING 'WIN1252';



