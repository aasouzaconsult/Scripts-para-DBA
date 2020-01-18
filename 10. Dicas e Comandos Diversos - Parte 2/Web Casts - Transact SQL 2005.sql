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

/***************************************
 * Usando o comando INTERCEPT e EXCEPT *
 ***************************************/
select NmTimeB from TbBrasileirao2008
except
select NmTimeP from TbPaulistao2008

/**************************
 * Usando o comando PIVOT *
 **************************/
Select * From TbPontuacao
PIVOT	(Sum (QtPont) for NmProd IN ([Camisa],[Gravata],[Calça])) Pvt

-- Exemplo 2
Select	* 
From	TbMovMerc
PIVOT	(count(Ok) for Mes IN 
([Janeiro],[Fevereiro],[Março],[Abril],[Maio],[Junho], [Julho],[Agosto],[Setembro],[Outubro],[Novembro],[Dezembro])) Pvt

/**********************************
 * Populando tabelas para Exemplos *
 **********************************/
create table TbPaulistao2008 (
	CdTimeP	int	identity(1,1) primary key
,	NmTimeP varchar(50)
)
--insert into TbPaulistao2008 values ('Barueri')
--insert into TbPaulistao2008 values ('Bragantino')
--insert into TbPaulistao2008 values ('Corinthians')
--insert into TbPaulistao2008 values ('Guarani')
--insert into TbPaulistao2008 values ('Guaratingua')
--insert into TbPaulistao2008 values ('Ituano')
--insert into TbPaulistao2008 values ('Juventus')
--insert into TbPaulistao2008 values ('Marilia')
--insert into TbPaulistao2008 values ('Mirassol')
--insert into TbPaulistao2008 values ('Noroeste')
--insert into TbPaulistao2008 values ('Palmeiras')
--insert into TbPaulistao2008 values ('Paulista')
--insert into TbPaulistao2008 values ('Ponte Preta')
--insert into TbPaulistao2008 values ('Portuguesa')
--insert into TbPaulistao2008 values ('Rio Claro')
--insert into TbPaulistao2008 values ('Rio Preto')
--insert into TbPaulistao2008 values ('Santos')
--insert into TbPaulistao2008 values ('São Caetano')
--insert into TbPaulistao2008 values ('São Paulo')
--insert into TbPaulistao2008 values ('Sertãozinho')

select * from TbPaulistao2008

create table TbBrasileirao2008 (
	CdTimeB	int	identity(1,1) primary key
,	NmTimeB varchar(50)
)
--insert into TbBrasileirao2008 values ('Atlético-MG')
--insert into TbBrasileirao2008 values ('Atlético-PR')
--insert into TbBrasileirao2008 values ('Botafogo-RJ')
--insert into TbBrasileirao2008 values ('Coritiba')
--insert into TbBrasileirao2008 values ('Cruzeiro')
--insert into TbBrasileirao2008 values ('Figueirense')
--insert into TbBrasileirao2008 values ('Flamengo')
--insert into TbBrasileirao2008 values ('Fluminense')
--insert into TbBrasileirao2008 values ('Goiás')
--insert into TbBrasileirao2008 values ('Grêmio')
--insert into TbBrasileirao2008 values ('Internacional')
--insert into TbBrasileirao2008 values ('Ipatinga-MG')
--insert into TbBrasileirao2008 values ('Náutico')
--insert into TbBrasileirao2008 values ('Palmeiras')
--insert into TbBrasileirao2008 values ('Portuguesa-SP')
--insert into TbBrasileirao2008 values ('Santos') 
--insert into TbBrasileirao2008 values ('São Paulo')
--insert into TbBrasileirao2008 values ('Sport') 
--insert into TbBrasileirao2008 values ('Vasco da Gama')
--insert into TbBrasileirao2008 values ('Vitória-BA')

-- Exemplo para o PIVOT
use SQLEstudo
create table TbPontuacao (
	NmPess	varchar(30)
,	NmProd	varchar(30)
,	QtPont	int	
)
--drop table TbPontuacao
select * from TbPontuacao

--insert into TbPontuacao values ('Alex', 'Camisa', 50)
--insert into TbPontuacao values ('Antonio', 'Camisa', 50)
--insert into TbPontuacao values ('Alex', 'Gravata', 20)
--insert into TbPontuacao values ('Severino', 'Gravata', 20)
--insert into TbPontuacao values ('Tiririca', 'Calça', 100)
--insert into TbPontuacao values ('Manuel', 'Calça', 100)
--insert into TbPontuacao values ('Severino', 'Camisa', 50)
--insert into TbPontuacao values ('Alex', 'Calça', 100)
--insert into TbPontuacao values ('Tiririca', 'Gravata', 20)
--insert into TbPontuacao values ('Alex', 'Gravata', 20)

create table TbMovMerc (
	NmObj	varchar(50)
,	Mes		varchar(20)
,	Ok		int
)
--drop table TbMovMerc
select * from TbMovMerc

--insert into TbMovMerc values ('Produto 01', 'Março', 1)
--insert into TbMovMerc values ('Produto 01', 'Abril', 1)
--insert into TbMovMerc values ('Produto 01', 'Maio', 1)
--insert into TbMovMerc values ('Produto 02', 'Janeiro', 1)
--insert into TbMovMerc values ('Produto 02', 'Novembro', 1)
--insert into TbMovMerc values ('Produto 03', 'Dezembro', 1)
--insert into TbMovMerc values ('Produto 04', 'Março', 1)
--insert into TbMovMerc values ('Produto 04', 'Dezembro', 1)
--insert into TbMovMerc values ('Produto 05', 'Maio', 1)
--insert into TbMovMerc values ('Produto 05', 'Julho', 1)
--insert into TbMovMerc values ('Produto 06', 'Janeiro', 1)
--insert into TbMovMerc values ('Produto 06', 'Agosto', 1)
--insert into TbMovMerc values ('Produto 06', 'Março', 1)
--insert into TbMovMerc values ('Produto 07', 'Fevereiro', 1)
--insert into TbMovMerc values ('Produto 07', 'Abril', 1)
--insert into TbMovMerc values ('Produto 08', 'Janeiro', 1)
--insert into TbMovMerc values ('Produto 08', 'Fevereiro', 1)
--insert into TbMovMerc values ('Produto 08', 'Junho', 1)
--insert into TbMovMerc values ('Produto 08', 'Setembro', 1)
--insert into TbMovMerc values ('Produto 08', 'Outubro', 1)