-- Criando tabela de Pessoas
Create table pessoas (
	id serial not null
,	nome varchar(100) not null
,	cpf varchar(14) not null
,	constraint pk_pessoas primary key (id)
,	constraint idx_pessoas_cpf unique(cpf)
);

Select * From pessoas

-- Adicionado comentario
COMMENT ON TABLE pessoas IS 'Tabela de pessoas';

﻿-- Criando tabela de contas
Create table contas (
	id serial not null
,	codigo_banco varchar(3) not null
,	codigo_agencia varchar(10) not null
,	numero_conta varchar(20) not null
,	digito_verificador_conta varchar not null
,	saldo numeric(15,2) not null default 0
,	pessoa_id integer not null
,	constraint pk_contas primary key (id)
,	constraint fk_contas_pessoas foreign key (pessoa_id) references pessoas(id) match simple -- combinação simples
	on update restrict -- Trata na tabela referenciada
	on delete restrict -- Trata na tabela referenciada (Não deixa deletar uma pessoa associada a conta - opção: restrict)
,	constraint idx_contas_conta unique (codigo_banco, codigo_agencia, numero_conta)
);

-- Opções de restrição
-- no action
-- set null http://www.uol.com.br/
-- set default
-- restrict
-- cascade

Select * From contas;

﻿-- Criando tabela de Transferencias
Create table transferencias (
	id serial not null
,	id_conta_origem integer not null
,	id_conta_destino integer not null
,	data date not null
,	valor numeric(15,2) not null
,	constraint pk_transferencias primary key (id)
,	constraint fk_destino foreign key (id_conta_destino) references contas (id) match simple
	on update restrict
	on delete restrict
,	constraint fk_transferencias_origem foreign key (id_conta_origem) references contas (id) match simple
	on update restrict
	on delete restrict 
);

Select * From Transferencias;

COMMENT ON TABLE transferencias IS 'Tabela de transferencia';


-- Apagando tabelas
-- drop table nome_tabela;
-- drop table nome_tabela cascade; -- comando destruidor

--******************************
--* Inserindo dados via INSERT *
--******************************
-- * em campos seriais (identity) se informado pode quebrar a sequencia
Insert into pessoas(nome, cpf) values ('Fulano'  , '11111111111111');
Insert into pessoas(nome, cpf) values ('Beltrano', '22222222222222');
Insert into pessoas(nome, cpf) values ('Alex'    , '33333333333333');
Insert into pessoas(nome, cpf) values ('Nome 1'  , '12121212121212');

Select * From pessoas;

--Copia de uma grande volume de dados (como se fosse o Bulk Insert)
-- COPY (Não funciona no pg_admin, o arquivo deve ficar em um diretorio que o usuário postgres tenha acesso)
-- sintaxe: copy tabela from 'arquivo.csv' CSV header; -- se informar o header o arquivo a ser importado deve 
--ter a primeira linha com um cabeçalho.
copy contas(codigo_banco, codigo_agencia, numero_conta, digito_verificador_conta, saldo, pessoa_id) 
from '/tmp/Contas.csv' CSV;

insert into contas (codigo_banco, codigo_agencia, numero_conta, digito_verificador_conta, saldo, pessoa_id)
values (11, 255, 56478, 1, 3500.50, 4); 

-- Teste de violação de integridade (idx_contas_conta)
insert into contas (codigo_banco, codigo_agencia, numero_conta, digito_verificador_conta, saldo, pessoa_id)
values (11, 255, 56478, 1, 3500.50, 5);

Select * From contas;

-- UPDATE
update tabela set campos = valor where condição

-- DELETE -- Transacional / executa triggers
--begin transaction
DELETE from tabela where condição
--rollback
--commit

-- TRUNCATE -- não transacional e não executa triggers
-- Apaga no nivel folha
TRUNCATE table tabela;
TRUNCATE table tabela cascade;

-- CONSULTAS
Select * From pessoas;

Select id, nome as "nome_correntista", cpf From pessoas;

Select id, nome, cpf From pessoas Where id = 1;

Select id, nome, cpf From pessoas Where cpf = '11111111111111'; 

Select id, nome, cpf From pessoas Order by nome asc;

Select * From pessoas Where nome like '%elt%';

Select * From pessoas Where id in (1,2,3);

Select * From pessoas Where id between 1 and 4;

Select * From pessoas Limit 1; -- como se fosse o Top do SQL Server


-- JOINS 
Select 	c.codigo_banco
,	c.numero_conta
,	c.saldo
,	p.cpf
,	p.nome
From	contas c
join	pessoas p on p.id = c.pessoa_id

-- Subconsultas
-- Atenção em relação a performance
Select 	* 
From	Contas
Where	pessoa_id in (Select id From Pessoas)

Select 	C.* 
From	Contas C
join	Pessoas P on P.id = C.pessoa_id

-- Proxima Aula
-- Indices
-- Visões
-- Funções
-- Triggers
-- Procedimentos