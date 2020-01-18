/***************************************************************
 * Usando o comando PIVOT, converte valores(linhas) em colunas *
 ***************************************************************/

--Definição do PIVOT e UNPIVOT
--http://msdn2.microsoft.com/en-us/library/ms177410.aspx

--Criando a tabela para o exemplo
create table TbPontuacao (
	NmPess	varchar(30)
,	NmProd	varchar(30)
,	QtPont	int	
) 
--drop table TbPontuacao

-- Populando a tabela
insert into TbPontuacao values ('Alex', 'Camisa', 50)
insert into TbPontuacao values ('Antonio', 'Camisa', 50)
insert into TbPontuacao values ('Alex', 'Gravata', 20)
insert into TbPontuacao values ('Batoré', 'Gravata', 20)
insert into TbPontuacao values ('Tiririca', 'Calça', 100)
insert into TbPontuacao values ('Barnabé', 'Calça', 100)
insert into TbPontuacao values ('Batoré', 'Camisa', 50)
insert into TbPontuacao values ('Alex', 'Calça', 100)
insert into TbPontuacao values ('Tiririca', 'Gravata', 20)
insert into TbPontuacao values ('Alex', 'Gravata', 20)

-- O Exemplo
Select * From TbPontuacao
PIVOT	(Sum (QtPont) for NmProd IN ([Camisa],[Gravata],[Calça])) Pvt

--Autor: Antonio Alex
--Data.: 02/03/2008
--Email: pessoalex@hotmail.com