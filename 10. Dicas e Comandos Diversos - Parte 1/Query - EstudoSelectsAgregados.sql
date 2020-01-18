-- EstudoSelectsAgregados.sql >> use EstudoSQL
--##############################################################
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