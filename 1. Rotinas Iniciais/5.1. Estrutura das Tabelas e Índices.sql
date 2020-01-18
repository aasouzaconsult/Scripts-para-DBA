--Tabelas e índices: como são estruturados e armazenados internamente pelo SQL Server?

-- Espaço utilizado por uma tabela (http://msdn.microsoft.com/pt-br/library/ms188776.aspx)
exec sp_spaceused 'TbCov', @updateusage = N'TRUE';

-- Informações da Tabela
exec sp_help TbMde

-- Paginas corrompidas
select * from msdb..Suspect_pages

/**************************************
 ** Quantidade de linhas por Tabelas **
 **************************************/
SELECT	o.name AS "Nome da Tabela"
,		i.rowcnt AS "Total de Linhas"
FROM	sysobjects o, sysindexes i WHERE i.id = o.id
AND		indid IN(0,1) AND o.name <> 'sysdiagrams' AND o.xtype = 'U'
Order by
		i.rowcnt desc

-- Quantidade de Linha + Espaço por tabela
SELECT	OBJECT_NAME(ps.object_id) As Tabela
,		Row_count As Linhas
,		SUM(CASE WHEN index_id <= 1 THEN convert(real,in_row_used_page_count) ELSE 0 END) * 8192 / 1024 / 1024 as Total_Tabela_Usado_MB
,		SUM(CASE WHEN index_id > 1 THEN convert(real,in_row_used_page_count) ELSE 0 END) *  8192 / 1024 / 1024 as Total_Indice_Usado_MB
FROM	sys.dm_db_partition_stats PS
GROUP BY
		OBJECT_NAME(ps.object_id), Row_Count
HAVING	SUM(CASE WHEN index_id <= 1 THEN convert(real,in_row_used_page_count) ELSE 0 END) * 8192 / 1024 / 1024  <> 0
ORDER BY
		 SUM(CASE WHEN index_id <= 1 THEN convert(real,in_row_used_page_count) ELSE 0 END) * 8192 / 1024 / 1024 desc


/********************************************
 ** Espaço utilizado por tabelas e índices **
 ********************************************/
SELECT	OBJECT_NAME(ps.object_id) As Tabela
,		Row_count As Linhas
,		SUM(CASE WHEN index_id <= 1 THEN convert(real,in_row_used_page_count) ELSE 0 END) * 8192 / 1024 / 1024 as Total_Tabela_Usado_MB
--,		SUM(CASE WHEN index_id <= 1 THEN convert(real,in_row_reserved_page_count) ELSE 0 END) * 8192 / 1024 / 1024 as Total_Tabela_Reservado_MB
,		SUM(CASE WHEN index_id > 1 THEN convert(real,in_row_used_page_count) ELSE 0 END) *  8192 / 1024 / 1024 as Total_Indice_Usado_MB
--,		SUM(CASE WHEN index_id > 1 THEN convert(real,in_row_reserved_page_count) ELSE 0 END) * 8192 / 1024 / 1024 as Total_Indice_Reservado_MB
,		[% do Tamanho Indice em relação a tabela]
			 = (((SUM(CASE WHEN index_id > 1 THEN convert(real,in_row_used_page_count) ELSE 0 END) *  8192 / 1024 / 1024) 
				- (SUM(CASE WHEN index_id <= 1 THEN convert(real,in_row_used_page_count) ELSE 0 END) * 8192 / 1024 / 1024))
					/ (SUM(CASE WHEN index_id <= 1 THEN convert(real,in_row_used_page_count) ELSE 0 END) * 8192 / 1024 / 1024)) * 100
FROM	sys.dm_db_partition_stats PS
GROUP BY
		OBJECT_NAME(ps.object_id), Row_Count
having (SUM(CASE WHEN index_id <= 1 THEN convert(real,in_row_used_page_count) ELSE 0 END) * 8192 / 1024 / 1024) < (SUM(CASE WHEN index_id > 1 THEN convert(real,in_row_used_page_count) ELSE 0 END) *  8192 / 1024 / 1024)
and		SUM(CASE WHEN index_id <= 1 THEN convert(real,in_row_used_page_count) ELSE 0 END) * 8192 / 1024 / 1024 <> 0
and		SUM(CASE WHEN index_id > 1 THEN convert(real,in_row_used_page_count) ELSE 0 END) *  8192 / 1024 / 1024 <> 0
ORDER BY
		-- Total_Tabela_Usado_MB DESC -- Tamanho da Tabela
		 Row_count DESC -- Numero de Linhas

/***********
 * Tabelas * 
 ***********/
--create table TbEstudo_A( 
--	CdEstudo int identity (1,1) not null
--,	NmEstudo varchar(100) not null
--,	Valor	tinyint null ) --Tabela Heap, ou seja, sem indices

--drop table TbEstudo_A

select object_id('TbEstudo_A')
select * from sys.tables where object_id = object_id('TbEstudo_A')
select * from sys.indexes where object_id = object_id('TbEstudo_A')
Select * from sys.partitions where object_id = object_id('TbEstudo_A')

-- Alocação na partição (1 Partição pode ter vários Unidades de Alocação(AU))
-- Ver as páginas utilizadas (*)
Select		AU.*
From		sys.allocation_units as AU
inner join	sys.partitions as P on AU.container_id = P.partition_id
Where		object_id = object_id('TbEstudo_A')

--insert into  TbEstudo_A values ('Estudo 1', 1)
-- Ver agora a quantidade de páginas utilizadas (*)


-- (**) Ver o primeiro (first) registro da página (Modo Antigo)
-- Ver tb numero de tuplas
Select  * 
From	sys.sysindexes -- Antigamente
Where	Id = object_id('TbEstudo_A')	

DBCC TRACEON (3604)
DBCC PAGE (13, 1, 152, 2)
DBCC PAGE (13, 1, 152, 3)
-- DBCC PAGE (Num. Banco, Arquivo, Pagina, Visualizacao)

/* 
	* Cabeçalho tem 96 Bytes
	**Analisando o resultado do dbcc page:(OFFSET TABLE) - Referencias aos registros
	79 (0x4f) - 2062 (0x80e)             
	78 (0x4e) - 2037 (0x7f5) - Procuro 7f em DATA, exemplo: 
		2412C7F0:   646f2037 38300009 004f0000 004f0300 †do780...O...O..
		2412C{Referencia -> *7F*}0:   646f2037 38300009 004f0000 004f0300 †do {Registro -> *78*} 0...O...O..
*/

/* Num.Banco */  
select * from master.sys.databases

/* Arquivo */
-- 0x98000000 0100 (first registro(**))
-- 0100 > 0001 (inverte) = 1

/* Página */
-- 0x98000000 0100 (first registro(**))
-- 0x98000000 > 0x00000098 (inverte) = 98 (Hexadecimal) > Transformar em decimal = 152

-- Ver a Primeira página (Modelo Novo)
Select  AU.* 
From	sys.system_internals_allocation_units as AU
inner join	sys.partitions as P on AU.container_id = P.partition_id
Where	object_id = object_id('TbEstudo')	

/* Popular Tabela */
--Declare @i int
--Set		@i = 2 
--While (@i < 100)
--Begin
--	insert into TbEstudo_A values ('Estudo '+ (convert(varchar(100), @i)), @i)
--	set @i = @i + 1
--End

--select * from TbEstudo_A

/***********
 * Indices * 
 ***********/
