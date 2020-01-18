use EstudoSQL;

drop table TbProduto
drop table TbFornecedor
drop table TbNotaFiscal
drop table TbForn_Prod

-- ######################
-- # Criação de Tabelas #
-- ######################

create table TbProduto (	
	CdProd		int identity(1,1) primary key
,	DescProd	varchar(50)
,	EstMinProd  float )

create table TbFornecedor (	
	CdForn		int identity(1,1) primary key
,	NmForn		varchar(50)
,	NmFantForn	varchar(30))

create table TbForn_Prod (	
	CdForn_Prod int identity(1,1) primary key
,	CdForn int foreign key references TbFornecedor(CdForn)
,	CdProd int foreign key references TbProduto(CdProd))

create table TbNotaFiscal (	
	CdNf		int identity(1,1) primary key
,	NumNf		int
,	CdFornNf	int constraint fk_TbFornec foreign key references TbFornecedor(CdForn)	
,	CdProdNf	int constraint fk_TbProduto foreign key references TbProduto(CdProd)
,	QtdProdNf	float 
,	VrUnitNf	float
,	VrTotal		float
,	DataNf		Smalldatetime)

-- ############
-- # Insert's #
-- ############

insert into TbProduto values ('Mouse PS2 Branco', 100) 
insert into TbProduto values ('Mouse PS2 Preto', 100)
insert into TbProduto values ('Teclado PS2 Branco', 50)
insert into TbProduto values ('Teclado PS2 Preto', 50)
insert into TbProduto values ('Caixa de Som VQD', 25)
insert into TbProduto values ('Monitor LCD Sony', 3)

insert into TbFornecedor values ('Silicon Tech do Brasil', 'SiliconTech')
insert into TbFornecedor values ('Nagem Informatica', 'Nagem')
insert into TbFornecedor values ('IByte Informatica', 'IByte')
insert into TbFornecedor values ('Fortaleza Informatica', 'Fortaleza Informatica')
insert into TbFornecedor values ('Vixe que Doidera Informatica', 'V.Q.D')

insert into  TbForn_Prod values (1,1)
insert into  TbForn_Prod values (1,2)
insert into  TbForn_Prod values (1,3)
insert into  TbForn_Prod values (1,6)
insert into  TbForn_Prod values (2,4)
insert into  TbForn_Prod values (2,5)
insert into  TbForn_Prod values (2,6)
insert into  TbForn_Prod values (3,1)
insert into  TbForn_Prod values (3,3)
insert into  TbForn_Prod values (4,2)
insert into  TbForn_Prod values (4,4)
insert into  TbForn_Prod values (5,1)
insert into  TbForn_Prod values (5,2)
insert into  TbForn_Prod values (5,3)
insert into  TbForn_Prod values (5,4)
insert into  TbForn_Prod values (5,5)
insert into  TbForn_Prod values (5,6)

--NumNF, CdForn, CdProd, QtdProd, VrUnit, VrTotal
insert into TbNotaFiscal values (21250, 1, 2, 50, 15.00, null, '01/06/2007')
insert into TbNotaFiscal values (22250, 3, 2, 50, 16.00, null, '30/06/2007')
insert into TbNotaFiscal values (22251, 3, 4, 20, 20.00, null, '05/09/2007')
insert into TbNotaFiscal values (21251, 1, 6, 03, 500.00, null, '01/07/2007')
insert into TbNotaFiscal values (23000, 4, 5, 15, 25.00, null, '10/06/2007')
insert into TbNotaFiscal values (21000, 5, 5, 10, 30.00, null, '28/06/2007')
insert into TbNotaFiscal values (19050, 2, 1, 80, 11.00, null, '01/05/2007')
insert into TbNotaFiscal values (21001, 5, 3, 10, 25.00, null, '15/05/2007')
insert into TbNotaFiscal values (19051, 2, 3, 05, 26.00, null, '29/06/2007')
insert into TbNotaFiscal values (23001, 4, 1, 20, 11.50, null, '23/08/2007')

-- #############
-- #  UpDates  #
-- #############
--Update	TbFornecedor
--Set		NmForn = 'Vixe que Doideira Corporation'
--where	CdForn = 5

-- #############
-- # Consultas #
-- #############

select * from TbNotaFiscal
select * from TbProduto
select * from TbFornecedor
select * from TbForn_Prod

-- *********************************
select -- Fornecedor Produto
		Forn.CdForn 
,		Forn.NmForn
,		Prod.CdProd
,		Prod.DescProd
from	TbFornecedor Forn
join	TbForn_Prod Forn_Prod on Forn_Prod.CdForn = Forn.CdForn 
join	TbProduto Prod on Prod.CdProd = Forn_Prod.CdProd

-- *********************************
select	--Top 1 --Acha a ultima NF (por data)
	NotaFiscal = Nf.CdNf
,	CodigoProduto = Prod.CdProd
,	Produto = Prod.DescProd
,	CodigoFornecedor = Forn.CdForn
,	Fornecedor = Forn.NmForn
,	ValorUnitario = Nf.VrUnitNf
,	ValorTotal = Nf.VrTotal
,	DataNf = Nf.DataNf
from	TbNotaFiscal Nf 
join	TbProduto Prod on Prod.CdProd = Nf.CdProdNf
join	TbFornecedor Forn on Forn.CdForn = Nf.CdFornNf
order by
	Nf.DataNf	desc --Acha a ultima NF (por data)
--Objetivo: Achar o Ultimo valor unitário de cada produto

-- *****************************
-- Achar os item comuns nas NF's
-- *****************************
Select 
	CdProdNf 
From TbNotaFiscal
Group By
	CdProdNf

-- **********************
-- Usando Select / Select
-- **********************
Select 
		Venda	= Venda.CdVenda
,		Produto = Produto.DescProd
,		Qtd		= Venda.QtdProdVenda
,		VrUnit	= Venda.VrUnitProdVenda
,		TotalItem	= Venda.VrUnitProdVenda * Venda.QtdProdVenda
,		Total	= 0
From 
		TbVenda Venda
join	(select CdProd, DescProd from TbProduto) Produto on Produto.CdProd = Venda.CdProdVenda
Group by
		Venda.VrUnitProdVenda
,		Venda.CdVenda
,		Produto.DescProd
,		Venda.QtdProdVenda
union
Select 
		Venda	= null
,		Produto = null
,		Qtd		= null
,		VrUnit	= null
,		TotalItem	= null
,		Total = sum(VrUnitProdVenda * QtdProdVenda)
From 
		TbVenda Venda
join	(select CdProd, DescProd from TbProduto) Produto on Produto.CdProd = Venda.CdProdVenda
Group by
		Venda.VrUnitProdVenda

--######################
--# SELECT'S AGREGADOS #
--######################
use EstudoSQL

-- SUM: soma/total - ok
-- AVG: média - ok
-- COUNT: contagem - ok
-- MIN: mínimo - ok
-- MAX: máximo - ok
-- Cláusula HAVING;

--##############################################################
-- Saber a quantidade de cada produto já vendido (USO DO SUM)
--Select
--	Produto = Prod.DescProd
--,	SUM (Nf.QtdProdNf) Quantidade
--From	TbNotaFiscal Nf 
--join	TbProduto Prod on Prod.CdProd = Nf.CdProdNf
--Group by
--	Prod.DescProd

--##############################################################
-- Saber a quantidade de vezes que determinado produto foi vendido (USO DO COUNT)
--Select
--	Prod.CdProd
--,	Produto = Prod.DescProd
--,	count (Prod.CdProd) Quantidade
--From	TbNotaFiscal Nf 
--join	TbProduto Prod on Prod.CdProd = Nf.CdProdNf
--Group by
--	Prod.CdProd
--,	Prod.DescProd

--##############################################################
-- Saber a média de Venda dos Produtos 1 e 2 (USANDO AVG e Union)
--Select 
--		Informação = 'Média'
--,		Descrição = NULL
--,		Valor = AVG (Nf.QtdProdNf)
--From 
--		TbNotaFiscal Nf
--join	TbProduto Prod on Prod.CdProd = Nf.CdProdNf
--Where	Prod.CdProd in (1,2)
--union
--Select 
--		Informação = 'Produtos Calculados'
--,		Descrição = Prod.DescProd
--,		Media	= NULL
--From	TbProduto Prod
--where	Prod.CdProd in (1,2)

--##############################################################
-- Maior ou Menor preço dos produtos (USANDO MAX, MIN e HAVING)
--select
--		CodigoProduto = Prod.CdProd
--,		Produto = Prod.DescProd
--,		max (Nf.VrUnitNf) --Acha o Maior
--,		min (Nf.VrUnitNf) --Acha o Menor
--from	TbNotaFiscal Nf 
--join	TbProduto Prod on Prod.CdProd = Nf.CdProdNf
--group by
--		Prod.CdProd
--,		Prod.DescProd
----,		Nf.VrUnitNf
----Having	Nf.VrUnitNf < 20


select	--Top 1 --Acha a ultima NF (por data)
	NotaFiscal = Nf.CdNf
,	CodigoProduto = Prod.CdProd
,	Produto = Prod.DescProd
,	CodigoFornecedor = Forn.CdForn
,	Fornecedor = Forn.NmForn
,	Quantidade = Nf.QtdProdNf
,	ValorUnitario = Nf.VrUnitNf
,	ValorTotal = Nf.VrTotal
,	DataNf = Nf.DataNf
from	TbNotaFiscal Nf 
join	TbProduto Prod on Prod.CdProd = Nf.CdProdNf
join	TbFornecedor Forn on Forn.CdForn = Nf.CdFornNf
order by
	--Prod.CdProd
Nf.DataNF	desc --Acha a ultima NF (por data)


--#####################
--# MANIPULANDO DATAS #
--#####################

-- use master
Select
	name
,	crdate
,	DiasCriado = DATEDIFF(DAY,crdate,getdate())
,	AnosCriado = DATEDIFF(YEAR,crdate,getdate())
From master.dbo.sysdatabases

Select 
	datepart(dd, getdate()) as Dia
,	datepart(mm, getdate()) as Mes
,	datepart(yy, getdate()) as Ano

declare @Data SmallDateTime
set @Data = '20080101'
Select 
	datediff (day, @Data, GetDate()) as dias --Diferença em Dias da data que colocou
,	datediff (month, @Data, GetDate()) + 1 as Mes --Diferença em Meses da data que colocou
,	datediff (year, @Data, GetDate()) as Ano --Diferença em Anos da data que colocou
,	datediff (hour, @Data, GetDate()) as Horas
,	datediff (minute, @Data, GetDate()) as Minutos
,	datediff (second, @Data, GetDate()) as Segundos

declare @Data SmallDateTime
set @Data = '01/01/2008'

/* Validando Datas e Numeros */
select isdate (@Data) as DtValida -- Datas
select isnumeric (123) -- Numero

/* Conversão de date em varchar */
SELECT 'A data de hoje é: ' + CAST(@Data as varchar(11))
SELECT 'A data de hoje é: ' + CONVERT(varchar(11),@Data)