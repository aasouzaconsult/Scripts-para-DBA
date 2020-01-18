-- select * from sys.databases
-- create database BDTeste
use BDTeste

/*	Dúvida - Questão em concurso publico
	Trata-se de uma questão que foi utilizada em concursos publicos:
	Considere as tabelas R,S,T com 10, 30 e 50 registros respectivamente.
	O comando sql produz: Comando -> select sum(3) from r r1, r r2, s s1, t t1 

	Quantos registros serão produzidos? 
	A resposta é esta: Em virtude da ausência de operadores JOIN e de junções na cláusula WHERE
, normalmente teríamos um produto cartesiano produzindo uma quantidade de registros resultado da 
multiplicação dos registros de todas as tabelas o que inicialmente nos levaria a 15.000 registros. 
No entanto, como a função SUM é uma função de agregação e não há nenhuma cláusula GROUP BY, será 
produzido um único registro (possivelmente com o resultado igual a 45.000). 

	Exemplo desenvolvido no SQL Server 2005, para facilitar a compreensão: */ 

--create table R (codigo int identity(1,1)) 
--create table S (codigo int identity(1,1)) 
--create table T (codigo int identity(1,1)) 

--insert into R default values
--go 10 

--insert into S default values 
--go 30 

--insert into T default values 
--go 50 

Select sum(3) as 'Qtd. Registros' from R r1, R r2, S s1, T t1