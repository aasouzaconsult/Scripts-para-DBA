--***********************
--* AULA 1 - 17/09/2011 *
--***********************
-- Instalação do PostgreSQL

--***********************
--* AULA 2 - 24/09/2011 *
--***********************
-- Instalação do PostgreSQL (Revisão)

--***********************
--* AULA 3 - 01/10/2011 *
--***********************

-- Criando tabela de Pessoas
Create table pessoas (
	id serial not null
,	nome varchar(100) not null
,	cpf varchar(14) not null
,	constraint pk_pessoas primary key (id)
,	constraint idx_pessoas_cpf unique(cpf)
);

Select * From pessoas;

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

Select * From contas;

-- Opções de restrição
-- no action
-- set null
-- set default
-- restrict
-- cascade

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
Insert into pessoas(nome, cpf) values ('Fulano'         , '11111111111111');
Insert into pessoas(nome, cpf) values ('Beltrano'       , '22222222222222');
Insert into pessoas(nome, cpf) values ('Alex'           , '33333333333333');
Insert into pessoas(nome, cpf) values ('Yuri'           , '44444444444444');
Insert into pessoas(nome, cpf) values ('Jose Silveira'  , '55555555555555');
Insert into pessoas(nome, cpf) values ('Maria'          , '66666666666666');

Select * From pessoas;

--Copia de uma grande volume de dados (como se fosse o Bulk Insert)
-- COPY (Não funciona no pg_admin, o arquivo deve ficar em um diretorio que o usuário postgres tenha acesso)
-- sintaxe: copy tabela from 'arquivo.csv' CSV header; -- se informar o header o arquivo a ser importado deve 
--ter a primeira linha com um cabeçalho.
copy contas(codigo_banco, codigo_agencia, numero_conta, digito_verificador_conta, saldo, pessoa_id) 
from '/tmp/Contas.csv' CSV;

insert into contas (codigo_banco, codigo_agencia, numero_conta, digito_verificador_conta, saldo, pessoa_id)
values (1, 2558, 1234, 1, 3500.50, 1); 
insert into contas (codigo_banco, codigo_agencia, numero_conta, digito_verificador_conta, saldo, pessoa_id)
values (3, 1888, 2345, 2, 3250.00, 2); 
insert into contas (codigo_banco, codigo_agencia, numero_conta, digito_verificador_conta, saldo, pessoa_id)
values (5, 1532, 34567, 8, 10000.00, 3); 
insert into contas (codigo_banco, codigo_agencia, numero_conta, digito_verificador_conta, saldo, pessoa_id)
values (5, 1532, 34568, 9, 500.00, 6); 
insert into contas (codigo_banco, codigo_agencia, numero_conta, digito_verificador_conta, saldo, pessoa_id)
values (2, 998, 568, 1, 1758.32, 4); 

Select * From contas;

-- Teste de violação de integridade (idx_contas_conta)
insert into contas (codigo_banco, codigo_agencia, numero_conta, digito_verificador_conta, saldo, pessoa_id)
values (1, 2558, 1234, 1, 3500.50, 1);


-- UPDATE
--update tabela set campos = valor where condição

-- DELETE -- Transacional / executa triggers
--begin transaction
--DELETE from tabela where condição
--rollback
--commit

-- TRUNCATE -- não transacional e não executa triggers
-- Apaga no nivel folha
--TRUNCATE table tabela;
--TRUNCATE table tabela cascade;

-- CONSULTAS
Select * From pessoas;

Select id, nome as "nome_correntista", cpf From pessoas;

Select id, nome, cpf From pessoas Where id = 1;

Select id, nome, cpf From pessoas Where cpf = '11111111111111'; 

Select id, nome, cpf From pessoas Order by nome asc;

Select * From pessoas Where nome like '%elt%';

Select * From pessoas Where id in (1,2,3);

Select * From pessoas Where id between 1 and 4;

Select * From pessoas Limit 2; -- como se fosse o Top do SQL Server


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

-- Pessoas e contas associadas
Select 	C.* 
From	Contas C
join	Pessoas P on P.id = C.pessoa_id

-- Pessoas que não tem contas cadastradas
Select 	* 
From		pessoas p
left join	contas  c on c.pessoa_id = p.id
Where	p.id not in (Select pessoa_id From Contas)

-- Proxima Aula
-- Indices
-- Visões
-- Funções
-- Triggers
-- Procedimentos

--***********************
--* AULA 4 - 08/10/2011 *
--***********************

-- CRIANDO A VISÃO
Create view vw_contas as
select
      p.nome as "nome correntista",
      p.cpf as "cpf/cnpj",
      c.codigo_banco as banco,
      c.codigo_agencia as agencia,
      (c.numero_conta || '-' || c.digito_verificador_conta) as conta,
      c.saldo as saldo
from contas c
join pessoas p on (p.id = c.pessoa_id)
order by p.nome asc;

Select * From Vw_Contas;

--***********************
--* AULA 5 - 15/10/2011 *
--***********************

-- FUNÇÕES

/* *******************************************************************/
create or replace function data_atual() returns date as
$$
  declare data date;
  begin
    select current_date into data;
    return data;
  end;
$$
language plpgsql VOLATILE -- Linguagem que foi escrita (VOLATILE - Executa novamente)
--language plpgsql STRICT IMMUTABLE -- o STRICT IMMUTABLE se os paramentros são os mesmo retorna o mesmo resultado)

Select * from data_atual();

/* *******************************************************************/
create or replace function data_fixa() returns date as
$$
  declare data date := '20111030'::date; --::date convert para data
  begin
    return data;
  end;
$$
language plpgsql -- Linguagem que foi escrita

select * from data_fixa();

/* *******************************************************************/
-- simulando erro de constant
create or replace function data_constant() returns date as
$$
  declare data constant date not null default '20111030'::date; --::date convert para data
  begin	
    select current_date into data; -- tentando informar uma data para um campo definido como constant
    return data;
  end;
$$
language plpgsql -- Linguagem que foi escrita

select * from data_constant();

/* ****************************
   * DECLARAÇÃO DE PARAMETROS *
   **************************** */

create or replace function soma0(integer, integer) returns integer as
$$
  declare resultado integer;
  begin
     select ($1 + $2) into resultado;
     return resultado;
  end;
$$
language plpgsql

Select (Soma0 + 10) as soma From Soma0(1,2);
Select Soma0(12345678,76543210);

-- Parametros OUT / INOUT (procurar exemplos de utilização do INOUT)
create or replace function data_atual2(OUT data date) as
$$
   begin
      select current_date into data;
   end;
$$
language plpgsql

Select * from data_atual2();


-- Visualizar os Tipos e Languages (No PGADMIN > File > Options > Browser > Habilite TIPOS E LANGUAGES)

/* *********
   * TIPOS *
   ********* */

create type tp_pessoa as (
   nome varchar,
   idade integer
);

-- alterando a tabela de pessoas - adicionando idade
Alter Table pessoas
   add column idade integer;

select * from pessoas order by id;

Update 	pessoas Set idade = 23 Where id = 1;
Update 	pessoas Set idade = 25 Where id = 2;
Update 	pessoas Set idade = 30 Where id = 3;
Update 	pessoas Set idade = 32 Where id = 4;
Update 	pessoas Set idade = 16 Where id = 5;
Update 	pessoas Set idade = 18 Where id = 6;

-- Função usando TIPO
create or replace function fnc_pessoa_cpf (pcpf varchar) returns tp_pessoa as
$$
   declare resultado tp_pessoa;
   begin
	Select 	nome
	,	idade 
	into 	resultado
	From 	pessoas
	Where 	cpf = pcpf;

	return resultado;
   end;
$$
language plpgsql

Select * from fnc_pessoa_cpf('11111111111111');


-- RETORNANDO UM CONJUNTO DE RESULTADOS
-- SETOF varchar
-- SETOF Tp_Pessoa

create or replace function fnc_pessoa2 () returns setof tp_pessoa as
$$
   begin
     return query
	Select 	nome, idade From pessoas;
   end;
$$
language plpgsql

Select * From fnc_pessoa2();
Select * From fnc_pessoa2() Where idade between 25 and 31;

-- RETURNS TABLE (utiliza o mesmo principio do setof, só que não precisa definir o tipo)
-- exemplo 1
create or replace function fnc_pessoa3 () returns table(pnome varchar, pidade integer) as
$$
   begin
     return query
	Select 	nome, idade From pessoas;
   end;
$$
language plpgsql

Select * From fnc_pessoa3();
Select * From fnc_pessoa3() Where pidade between 25 and 31;

-- exemplo 2
create or replace function fnc_pessoa_cpf2 (pcpf varchar, OUT pnome varchar, OUT pidade int) as
$$
   begin
	Select 	nome, idade into pnome, pidade
	From 	pessoas
	Where 	cpf = pcpf;

   end;
$$
language plpgsql

Select * from fnc_pessoa_cpf2('11111111111111');

-- ATRIBUIÇÕES
create or replace function soma(v1 integer, v2 integer) returns integer as
$$
  declare resultado integer;
  begin
     resultado := (v1 + v2);
     return resultado;
  end;
$$
language plpgsql

Select (soma + 10) as soma From Soma(1,2);
Select Soma(12345678,76543210);

-- ou
create or replace function soma1(v1 integer, v2 integer) returns integer as
$$
  declare resultado integer;
  begin
     return (v1 + v2);
  end;
$$
language plpgsql

Select (soma1 + 11) as soma From Soma1(1,2);
Select Soma1(12345678,76543210);


-- Executando um comando sem retornos;
-- PERFORM query
-- Exemplo:
	perform insert into tb...

--- ATENÇÃO
INTO [STRICT] -- tratamento de insert into (só deixa adicionar 1 valor, senão colocar ele traz só o primeiro em caso de mais de uma linha e não ve como um erro)

-- INTO no plpgsql não é igual ao INTO do SQL.


-- COMANDOS DINAMICOS
EXECUTE
--modelo: execute 'Select * from bairros where uf = $1 and cidade = $2' into b USING 'CE', 'FORTALEZA';

--Exemplo (variando o campo de retorno)
create or replace function fnc_pessoa4(pcpf varchar, pcampo varchar) returns varchar as
$$
   declare 
	result varchar;
	sql text;
   
   begin
	sql := 'select ' || pcampo || ' from pessoas where cpf = $1';

	execute sql into result using pcpf;
	return result;
   end;
$$
language plpgsql

Select * from fnc_pessoa4('11111111111111', 'nome');
Select * from fnc_pessoa4('11111111111111', 'idade');

-- Exemplo "anyelement" - retornando o tipo original do campo (pseudo tipo)
-- O Magno ficou de preparar e trazer um exemplo

-- *************************************
-- ** EXEMPLO DE FUNÇÃO USANDO PYTHON **
-- *************************************

-- 1) instalar a linguagem do python

-- criar uma linguagem
create procedural language plpythonu --(u - acesso total a máquina, sem o u fica restrita ao banco)

create or replace function modulo_py(pnumero integer) returns varchar as
$$
	if pnumero % 2 == 0;
	   return 'par'
	else;
	   return 'impar'
$$
language plpythonu

Select modulo_py(5);

--***********************
--* AULA 6 - 22/10/2011 *
--***********************

-- Diagnostico de Resultados
create or replace function diag(pnome varchar) returns varchar as
$$
   declare 
	retorno varchar;
   begin
	Select cpf into retorno From pessoas Where nome = pnome;
	IF FOUND then -- Se retornou alguma coisa
		return retorno;
	ELSE
		return 'NÃO ENCONTRADO';
	END IF;
   end;
$$
language plpgsql

Select diag('Alex') as CPF;


create or replace function diag2(pnome varchar) returns int as
$$
   declare 
	retorno integer;
	d1 integer; -- diagnostico
   begin
	Select count(nome) into retorno From pessoas Where nome = pnome;
	GET DIAGNOSTICS d1 = ROW_COUNT;
	raise notice 'O valor de d1 é: %', d1;
	return retorno;
   end;
$$
language plpgsql

Select diag2('Alex') as CPF;



-- Estrutura de Controle
-- IF - THEN - ELSE
-- CASE

Select * From pessoas;
Select * From contas;
Select * From transferencias;
----------------------------------------------------

create type tp_base_idade as (
	id integer,
	nome varchar,
	cpf varchar,
	idade integer,
	base varchar
)

-- Analise de Idade
create or replace function fnc_base_idade(pcpf varchar) returns tp_base_idade as
$$
	Declare
		retorno tp_base_idade;
	Begin
		Select *
		into retorno
		From pessoas Where Cpf = pcpf;

		if not FOUND then
			raise exception 'pessoa não encontrada !';
		end if;

		if    retorno.idade <  18 then retorno.base := 'menor';
		elsif retorno.idade <= 25 then retorno.base := 'idade 1';
		elsif retorno.idade <= 45 then retorno.base := 'idade 2';
		elsif retorno.idade <= 65 then retorno.base := 'idade 3';
		elsif retorno.idade >  65 then retorno.base := '3 Idade';
		else  retorno.base := 'Idade não definida';
		end if;
			
		return retorno;
	End;
$$
language plpgsql

Select * from fnc_base_idade('11111111111111');
Select * From pessoas Where Cpf = '11111111111111';


----------------------------------------------------
-- Fazer exemplo de CASE


----------------------------------------------------
-- LOOP

create or replace function fnc_exibe_contador (count integer) returns setof integer as
$$
	declare
		fcount integer default 1;
	begin
		loop
			return next fcount;
			exit when count = fcount;
			fcount := fcount + 1;
		end loop;
	return;
	end;
$$
language plpgsql

Select * From fnc_exibe_contador(1000);

-- While
create or replace function fnc_exibe_contador_while (count integer) returns setof integer as
$$
	declare
		fcount integer default 1;
	begin
		while count >= fcount loop
			return next fcount;
			fcount := fcount + 1;
		end loop;
	return;
	end;
$$
language plpgsql

Select * From fnc_exibe_contador_while(1000);

-- FOR (variável inteira) -> by seria o incremento
create or replace function fnc_exibe_contador_for (count integer) returns setof integer as
$$
	declare
		fcount integer default 1;
	begin
		for fcount in 1..count by 1 loop
			return next fcount;
		end loop;
	return;
	end;
$$
language plpgsql

Select * From fnc_exibe_contador_for(1000);


----------------------------------------------------
-- Contador (Adicionando QTD do Contador)
create or replace function fnc_exibe_contador_for2 (count integer, p2 integer) returns setof integer as
$$
	declare
		fcount integer default 1;
	begin
		for fcount in 1..count by p2 loop
			return next fcount;
		end loop;
	return;
	end;
$$
language plpgsql

Select * From fnc_exibe_contador_for2 (1000, 5);

-- LOOP - Em resultado de consulta
create or replace function loop_consulta() returns setof pessoas as 
$$
	Declare
		reg record; -- record assume o valor
	Begin
		for reg in (select * from pessoas) loop
			reg.nome := upper(reg.nome); -- Deixar nome em maiusculo
			return next reg;
		end loop;

	return;
	
	End;
$$
language plpgsql

Select * from loop_consulta();

-------------------------------------
create or replace function fnc_base_idade_all() returns setof tp_base_idade as
$$
	Declare
		pessoas tp_base_idade;
	Begin
		for pessoas in (select * from pessoas) loop
		
			if    pessoas.idade <  18 then pessoas.base := 'menor';
			elsif pessoas.idade <= 25 then pessoas.base := 'idade 1';
			elsif pessoas.idade <= 45 then pessoas.base := 'idade 2';
			elsif pessoas.idade <= 65 then pessoas.base := 'idade 3';
			elsif pessoas.idade >  65 then pessoas.base := '3 Idade';
			else  pessoas.base := 'Idade não definida';
			end if;
			
			return next pessoas;
		end loop;
	return;
	End;
$$
language plpgsql

Select fnc_base_idade_all('11111111111111');


--***********************
--* AULA 6 - 29/10/2011 *
--***********************

-- Observações; PGPOLL (Espelhamento)
                -- balanceamento de carga na leitura

----------------
-- Transações --
----------------
Select * From contas;

begin;
	delete from contas;

rollback; -- desfazer (somente funções SQL, exemplo; insert, update, delete. ( x=x+1 não desfaz)) 
--commit; -- confirmar

--------------------------------------------------------------------
-- Qual erro que der ele já dá um rollback (Exemplo)
Select * From contas;

begin;
	delete from contas;
	select 0/2; -- dá um rollback automatico por causa do erro

rollback; -- desfazer
--------------------------------------------------------------------
-- SAVEPOINT
-- Criar um exemplo

--------------------------------------------------------------------
-- Tratamento de Excessão
-------------------------

Select 2/0;
--ERRO:  divisão por zero
--
--********** Error **********
--
--ERRO: divisão por zero
--SQL state: 22012 -- No Apendice A da Documentação do PostgreSQL (Sessão: 22 - Erro: 012)
--http://pgdocptbr.sourceforge.net/pg80/errcodes-appendix.html


create or replace function divide (a integer, b integer) returns numeric(15,2) as
$$
	begin
		return a/b;
	exception
		when division_by_zero then
			return -1;
	end;
$$
language plpgsql

Select divide(100,0);

--------------------------------------------------------------------
-- TRIGGERS
-----------
--NEW - Record dados novos
--OLD - Record dados antigos
--TG_NAME - Nome da trigger disparada
--TG_WHEN - BEFORE ou AFTER (After é mais utilizada para histórico/log - After não cabe tratamento de excessão)
--TG_OP - INSERT, UPDATE ou DELETE
--TG_TABLE_NAME - Tabela que disparou a trigger
--TG_TABLE_SCHEMA - SCHEMA a tabela que disparou a trigger

CREATE TABLE emp(
	nome varchar not null,
	salario numeric(15,2)
);

CREATE TABLE emp_audit(
	operacao char(1) NOT NULL,
	hora     timestamp NOT NULL,
	usuario  text NOT NULL,
	nome_emp text NOT NULL,
	salario	 numeric(15,2)
);

Select * From emp;
Select * From emp_audit;

-- TRIGGER AFTER
create or replace function processa_emp_audit() RETURNS TRIGGER AS $emp_audit$
BEGIN
	IF (TG_OP = 'DELETE') THEN
		INSERT INTO emp_audit SELECT 'D', now(), user, OLD.*; -- OLD.* - Campos da tabela emp;
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		INSERT INTO emp_audit SELECT 'U', now(), user, NEW.*; -- NEW.* - Campos da tabela emp;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO emp_audit SELECT 'I', now(), user, NEW.*; -- NEW.* - Campos da tabela emp;
		RETURN NEW;
	END IF;

	RETURN NULL; -- result é ignorado, quando for uma trigger after
END;
$emp_audit$ LANGUAGE plpgsql

CREATE TRIGGER emp_audit
   AFTER INSERT OR UPDATE OR DELETE ON emp
      FOR EACH ROW EXECUTE PROCEDURE processa_emp_audit(); -- FOR EACH ROW - para cada linha

INSERT INTO emp values ('Alex' , 100000.00);
INSERT INTO emp values ('João' , 5000.00)
,		       ('Maria', 12300.00);
INSERT INTO emp values ('José Ribeiro' , 3000.00);
INSERT INTO emp values ('Fabiano' , 1000.00);
INSERT INTO emp values ('Sr. Nimbus' , 2523500.00);

UPDATE 	emp
Set	salario = 15000.00
Where	nome = 'Fabiano';

Begin;
UPDATE 	emp
Set	salario = 5500.00
Where	nome = 'João';
rollback;

UPDATE 	emp
Set	salario = 5500.00
Where	nome = 'João';

DELETE FROM emp
WHERE   nome = 'Sr. Nimbus';

Select * From emp;
Select * From emp_audit;


-- TRIGGER BEFORE
CREATE OR REPLACE FUNCTION fnc_alt_pessoa() returns trigger as
$$
	begin
		new.nome := upper(new.nome);
		return new;
	end;
$$
language plpgsql

CREATE TRIGGER trg_pessoa 
   BEFORE INSERT OR UPDATE ON pessoas
      FOR EACH ROW EXECUTE PROCEDURE fnc_alt_pessoa(); -- FOR EACH ROW - para cada linha

INSERT INTO pessoas values (7, 'Sr. Nimbus', 44444444444, 32);

UPDATE pessoas set idade = 26 where nome = 'Beltrano';

Select * From Pessoas;

-- Coloca em maiuscula caso a idade for maior que 20
CREATE OR REPLACE FUNCTION fnc_alt_pessoa() returns trigger as
$$
	begin
		if NEW.idade > 20 then
			new.nome := upper(new.nome);
		end if;
		return new;
	end;
$$
language plpgsql

INSERT INTO pessoas values (8, 'Fabiano N. Amorim', 54545444444, 42);
INSERT INTO pessoas values (9, 'Luiz', 64545444444, 15);
Select * From Pessoas order by id;

-- Coloca em maiuscula caso a idade for maior que 20
CREATE OR REPLACE FUNCTION fnc_alt_pessoa1() returns trigger as
$$
	begin
		if NEW.idade > 20 then
			new.nome := upper(new.nome);
			return new;
		else
			raise notice 'Não é possível cadastrar pessoas com idade inferior a 20 anos';
			return null;
		end if;
	end;
$$
language plpgsql

CREATE TRIGGER trg_pessoa_naocrianca 
   BEFORE INSERT OR UPDATE ON pessoas
      FOR EACH ROW EXECUTE PROCEDURE fnc_alt_pessoa1(); -- FOR EACH ROW - para cada linha

INSERT INTO pessoas values (10, 'Joãozim', 94545444000, 19);
Select * From Pessoas;

--------------------------------------------
-- DICIONARIO DE RETORNO (TRANSFERENCIAS) --
--------------------------------------------
-- 0 - OK
-- 1 - Conta Origem inválida
-- 2 - Conta Destino inválida
-- 3 - Conta Origem e Destino iguais
-- 4 - Saldo insuficiente
-- 5 - Valor inválido
-- 6 - Data inválida

Select * From Pessoas;
Select * From Contas;
Select * From Transferencias;

CREATE TABLE log (log varchar);

CREATE OR REPLACE FUNCTION fnc_transferencias (pcta_origem integer, pcta_destino integer
					, pvalor numeric(15,2), pdata date)
RETURNS integer as
$$
	Declare
		vorigem record;
		vdestino record;
		retorno integer = 0;
		texto text;
		id_tra integer;
	Begin
		texto := 'REGISTRANDO TENTATIVAS DE TRANSFERENCIAS';
		-- validando se as contas são iguais
		if pcta_origem = pcta_destino then
			retorno := 3;
		end if;

		-- validando o valor que dever ser positivo
		if pvalor <= 0 then
			retorno :=  5;
		end if;

		-- validando a data de transferencia
		if pdata < now() then
			retorno :=  6;
		end if;
		
		-- validando se a conta de origem é uma conta valida
		select * into vorigem from contas
		where id = pcta_origem;

		if not FOUND then
			retorno := 1;
		end if;

		-- validando o saldo da conta de origemv
		if FOUND then
			if vorigem.saldo < pvalor then
				retorno := 4;
			end if;
		end if;

		-- validando se a conta destino é uma conta valida
		select * into vdestino from contas
		where id = pcta_destino;

		if not FOUND then
			retorno := 2;
		end if;

		if retorno = 0 then
			-- retira o saldo da origem
			update 	contas
			set	saldo = saldo - pvalor
			where 	id = pcta_origem;

			-- cadastra a transferencias
			insert into transferencias (id_conta_origem, id_conta_destino, data, valor)
			values (vorigem.id, vdestino.id, pdata, pvalor) returning id into id_tra;

			-- adiciona o saldo no destino
			update 	contas
			set	saldo = saldo + pvalor
			where 	id = pcta_destino;

		end if;

		insert into log values ('log de transf - usuario: ' || user || 
						       ' hora: '    || now()||
						       ' status: '  || retorno ||
						       ' id tranf: '|| coalesce(id_tra::varchar, ''));
		return retorno;
		
		Exception
			when others then 
				return -1;
				
	End;
$$
language plpgsql

Select * from Contas
Select fnc_transferencias(2,1,300.00,'2011-11-03');

Select * from log

--------------------------------------------------
-- ************ USANDO TRIGGER **************** --
--------------------------------------------------

CREATE OR REPLACE FUNCTION fnc_transferencias_trg (pcta_origem integer, pcta_destino integer
					, pvalor numeric(15,2), pdata date)
RETURNS integer as
$$
	Declare
		vorigem record;
		vdestino record;
		retorno integer = 0;
		texto text;
		id_tra integer;
	Begin
		texto := 'REGISTRANDO TENTATIVAS DE TRANSFERENCIAS';
		-- validando se as contas são iguais
		if pcta_origem = pcta_destino then
			retorno := 3;
		end if;

		-- validando o valor que dever ser positivo
		if pvalor <= 0 then
			retorno :=  5;
		end if;

		-- validando a data de transferencia
		if pdata < now() then
			retorno :=  6;
		end if;
		
		-- validando se a conta de origem é uma contva valida
		select * into vorigem from contas
		where id = pcta_origem;

		if not FOUND then
			retorno := 1;
		end if;

		-- validando o saldo da conta de origemv
		if FOUND then
			if vorigem.saldo < pvalor then
				retorno := 4;
			end if;
		end if;

		-- validando se a conta destino é uma conta valida
		select * into vdestino from contas
		where id = pcta_destino;

		if not FOUND then
			retorno := 2;
		end if;

		if retorno = 0 then
			-- retira o saldo da origem
			update 	contas
			set	saldo = saldo - pvalor
			where 	id = pcta_origem;

			-- cadastra a transferencias
			insert into transferencias (id_conta_origem, id_conta_destino, data, valor)
			values (vorigem.id, vdestino.id, pdata, pvalor) returning id into id_tra;

			-- adiciona o saldo no destino
			update 	contas
			set	saldo = saldo + pvalor
			where 	id = pcta_destino;
		else
			insert into log values ('TENTATIVA - log de transf - usuario: ' || user || 
						       ' hora: '    || now()||
						       ' status: '  || retorno ||
						       ' id tranf: '|| coalesce(id_tra::varchar, ''));
		end if;

		
		return retorno;
		
		Exception
			when others then 
				return -1;
				
	End;
$$
language plpgsql

-- usar a trigger
create or replace function fnc_tra() returns trigger as
$$
	Begin
		insert into log values ('O usuario: ' || user ||
				 ' cadastrou a transferencia: ' || NEW.id);
		return new;
	End;
$$
language plpgsql

CREATE TRIGGER trg_log_transf1
   AFTER INSERT ON transferencias
      FOR EACH ROW EXECUTE PROCEDURE fnc_tra(); -- FOR EACH ROW - para cada linha

Select * from Contas;
Select * from Transferencias;

Select fnc_transferencias_trg(1,2,300.00,'2011-11-04');
Select fnc_transferencias_trg(1,2,0.05,'2011-11-04');

Select * from log;


