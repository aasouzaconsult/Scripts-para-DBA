--create database BaseTeste
--use BaseTeste

--create table TbObj (
--	CdObj	int not null identity(1,1)
--,	NmObj	varchar(50)
--,	CdObjFilho int
--,	primary key (CdObj))
	
--drop table TbObj

--insert into TbObj values ('Notebook Acer TravelMate 4060 - Embalado', 1)
--insert into TbObj values ('Carcaça - Notebook Acer TravelMate 4060', 1)
--insert into TbObj values ('Teclado - Notebook Acer TravelMate 4060', 1)
--insert into TbObj values ('Processador - Notebook Acer TravelMate 4060', 2)
--insert into TbObj values ('Memória RAM - Notebook Acer TravelMate 4060', 2)
--insert into TbObj values ('Placa de Vídeo - Notebook Acer TravelMate 4060', 2)
--insert into TbObj values ('Placa de Rede - Notebook Acer TravelMate 4060', 2)
--insert into TbObj values ('Chip Intel Mobile- Notebook Acer TravelMate 4060', 6)
--
--update TbObj
--set	CdObjMae = 6
--where	CdObjMae = 7

--select
--		Objeto = Obj.CdObj
--,		NomeObjeto = Obj.NmObj
--,		ObjetoFilho = ObjFilho.CdObj
--,		NomeObjetoFilho = ObjFilho.NmObj
--from	TbObj Obj
--join	TbObj ObjFilho on ObjFilho.CdObjFilho = Obj.CdObj

--select count(*) from TbObj
--select count(distinct CdObjFilho) from TbObj

--select sum(CdObjFilho) from TbObj
--select sum(CdObjFilho)+ 3 from TbObj

--select avg(CdObjFilho) from TbObj

--select 17 / 8

--select
--		CdObjFilho as ObjMae
--,		Count(*) as ObjsFilhos
--From	TbObj
--Group by
--		CdObjFilho
----Having	Count(*) > 1

select * from TbObj

Select 
		Obj.CdObj
,		Obj.NmObj
,		Obj.CdObjFilho
From	TbObj Obj 
Where	Obj.CdObjFilho = (Select CdObjFilho From TbObj where CdObjFilho = 6)

--Select * 
--Into NovosProdutos -- Movimentacao, TbPrincipal e TbSecundaria
--From Teste..NovosProdutos

