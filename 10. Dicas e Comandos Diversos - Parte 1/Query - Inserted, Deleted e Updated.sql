use SQLEstudo

create table TbUsr (
	CdUsr int identity (1,1) primary key
,	NmUsr varchar(50)
,	TpUsr varchar(20))
--Drop Table TbUsr

select * from TbUsr
/***************************
 * Usando o comando OUTPUT *
 ***************************/
-- Criando tabela temporaria para insert
create table #LogUsrInsert (
	LogCdUsr int
,	LogNmUsr varchar(50)
,	Usuario sysname)
--drop table #LogUsrInsert
select * from #LogUsrInsert

-- Inserindo os dados + Output
insert into TbUsr (NmUsr, TpUsr)
Output INSERTED.CdUsr, INSERTED.NmUsr, suser_name() into #LogUsrInsert -- OUTPUT
values ('Antonio Alex', 'Database Adm')

-- Update nos Dados + Output
create table #LogUsrUpdate (
	TpUsrAntes	varchar(50)
,	TpUsrDepois varchar(50)
,	Usuario		sysname
)
--drop table #LogUsrUpdate
--select * from #LogUsrUpdate

--select * from TbUsr
Update	TbUsr 
Set		TpUsr = 'Analista de Sistemas'
Output	Deleted.TpUsr, Inserted.TpUsr, suser_name() into #LogUsrUpdate
Where	CdUsr = 3