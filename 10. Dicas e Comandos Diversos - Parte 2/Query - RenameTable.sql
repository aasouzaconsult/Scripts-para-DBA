
--create table TbTestes1(
--	CdTeste1		int identity(1,1) primary key
--,	NmTeste1		varchar(50)
--,	CdEquivTeste1	int
--,	foreign key (CdEquivTeste1) references TbEquivTeste1(CdEquiv)
--)

--create table TbEquivTeste1(
--	CdEquiv	int identity(1,1) primary key
--,	NmEquiv	varchar(50)
--)

--insert into TbEquivTeste1 values('Bate')
--insert into TbEquivTeste1 (NmEquiv) values('Mia')
--insert into TbEquivTeste1 values('Canta')

--update	TbEquivTeste1
--set		NmEquiv = 'Late'
--where	CdEquiv	= 1

--insert into TbTestes1 values ('Passaros', 3)
--insert into TbTestes1 values ('Cachorro', 1)
--insert into TbTestes1 values ('Gato', 2)

--select * from TbTestes1
--select * from TbEquivTeste1

Select
			Teste1.NmTeste1
,			Equiv1.NmEquiv
From		TbTestes1 Teste1
join		TbEquivTeste1 Equiv1 on Equiv1.CdEquiv = Teste1.CdEquivTeste1

--Mudar o Nome de uma Tabela
--Renomear
Exec sp_rename 'TbTeste', 'TbTestes1' --Testado e funciona
--Ou vá pelo Object Explorer com o Botão direito e rename.

/* 
	Ou ainda cria-se uma nova tabela com os mesmos atributos: 
	Na tabela original, botão direito > Script Table as > Create to > New Query Editor Window
	Altere o nome da Tabela para a que deseja e depois é só alimenta-lá com os dados da tabela
  anterior, conforme abaixo...
*/
-- Tabela criada
select * from tbteste
-- Alimentação da mesma
insert into TbTeste (NmTeste1, CdEquivTeste1)
	select NmTeste1, CdEquivTeste1 from TbTestes1