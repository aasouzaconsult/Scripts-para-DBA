--select * from contas;

/* *******************************************************************
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

*/
--select * from data_atual();

/* *******************************************************************
create or replace function data_fixa() returns date as
$$
  declare data date := '20111030'::date; --::date convert para data
  begin
    return data;
  end;
$$
language plpgsql -- Linguagem que foi escrita
*/
--select * from data_fixa();

/* *******************************************************************
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
*/
--select * from data_constant();

/* ****************************
   * DECLARAÇÃO DE PARAMETROS *
   **************************** */
/*
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
*/

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

select * from pessoas;

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

-- ou
create or replace function soma1(v1 integer, v2 integer) returns integer as
$$
  declare resultado integer;
  begin
     return (v1 + v2);
  end;
$$
language plpgsql

Select (soma + 10) as soma From Soma(1,2);
Select Soma(12345678,76543210);

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

Select diag('AlexYS') as CPF;


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

Select diag2('1Alex') as CPF;

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

Select fnc_base_idade('11111111111111');
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
		--for fcount in 1..count by 1 loop
		for fcount in 1..count by 1 loop
			return next fcount;
		end loop;
	return;
	end;
$$
language plpgsql

Select * From fnc_exibe_contador_for(1000);

----------------------------------------------------
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
