--create database Empresa
--drop database empresa
use Empresa

--drop table empregado
--drop table departamento
--drop table empDepto
--drop table dependente

create table empregado
( cdEmpregado int identity(1,1),
  cpf int not null primary key,
  nome varchar(50) not null,
  endereco varchar(45),
  sexo varchar(10),
  salario float not null,
  data SmallDateTime not null
)

create table departamento
( numDepto int identity(1,1) not null,
  nomeDepto varchar(50) not null,
  primary key (numDepto)
)

create table empDepto
( cpfEmp int not null,
  numDepto int not null,
  dtAdm SmallDateTime not null,
  primary key (cpfEmp,numDepto),
  foreign key (cpfEmp) references empregado (cpf),
  foreign key (numDepto) references departamento (numDepto)
)

create table dependente
( numDep int identity(1,1) not null,
  cpfEmp int not null,
  nomeDep varchar(50) not null,
  sexoDep varchar(10) not null,
  dataNascDep SmallDateTime not null,
  parentesco varchar(20) not null,
  primary key (numDep,cpfEmp),
  foreign key (cpfEmp) references empregado (cpf)
)

create table projeto
( numProj int identity(1,1) not null,
  nomeProj varchar(30) not null,
  localizacao varchar(20),
  numDepto int not null,
  primary key (numProj),
  foreign key (numDepto) references departamento (numDepto)
)

create table empProj
( cpfEmp int not null,
  numProj int not null,
  primary key (cpfEmp,numProj),
  foreign key (cpfEmp) references empregado (cpf),
  foreign key (numProj) references projeto (numProj)
)

INSERT INTO departamento VALUES ('Informática')
INSERT INTO departamento VALUES ('Comercial')
INSERT INTO departamento VALUES ('Custos')
INSERT INTO departamento VALUES ('Compras')
INSERT INTO departamento VALUES ('Producao')

select * from departamento

SELECT cpf,nome FROM empregado WHERE Nome != 'Antonio Alex';

Observações:
*** date -> Ano-Mes-Dia ***


Questões:
2) SELECT data,endereco FROM empregado e where e.nome='Antonio Alex'

3) SELECT e.nome,e.endereco FROM empregado e, departamento d, empdepto ed where e.cpf=ed.cpfEmp and ed.numDepto=d.numDepto and d.nomeDepto='Informatica'

4) 

5) SELECT nome, endereco FROM empregado e where e.endereco like '%Fort%'

6) SELECT nome as Nome, data as Data_Admissão FROM empregado e where e.data between '1970-01-01' and '1979-12-31'

7) select e.nome, ed.numDepto from empregado e, empdepto ed where e.cpf=ed.cpfEmp and ed.numDepto=3 and e.salario between 1000.00 and 3000.00