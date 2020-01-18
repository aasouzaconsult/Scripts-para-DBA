-- ********************************
-- * Analise de Índice por Tabela *
-- ********************************

Declare @Tabela varchar(255)
Set		@Tabela = 'TbArvPes'

Select 'Espaço utilizado por uma tabela ( ' + @Tabela + ' )' 
-- Espaço utilizado por uma tabela (http://msdn.microsoft.com/pt-br/library/ms188776.aspx)
exec sp_spaceused @Tabela, @updateusage = N'TRUE';

Select 'Quantidade de índices por tabela ( ' + @Tabela + ' )'
Select	[Nome da Tabela] = o.name
,		[Qtd de Índices] = count(o.name)
From	sys.indexes i
join	sys.objects o on o.object_id = i.object_id
Where	o.name = @Tabela
Group by
		o.name
Order by 
		count(o.name) desc

Select 'Informações de indices da Tabela: ' + @Tabela
exec sp_helpindex @Tabela

Select 'Consulta a utilização dos índices por tabela ( ' + @Tabela + ' )'
-- ************************************************
-- * Consulta a utilização dos índices por tabela *
-- ************************************************
SELECT	DB_NAME(database_id) As Banco
,		OBJECT_NAME(I.object_id) As Tabela
,		I.Name As Indice
,		U.User_Seeks As Pesquisas
,		U.User_Scans As Varreduras
,		U.User_Lookups As LookUps
,		U.User_Updates As Updates
,		U.Last_User_Seek As UltimaPesquisa
,		U.Last_User_Scan As UltimaVarredura
,		U.Last_User_LookUp As UltimoLookUp
,		U.Last_User_Update As UltimaAtualizacao
FROM	sys.indexes As I
LEFT OUTER JOIN sys.dm_db_index_usage_stats As U ON I.object_id = U.object_id 
	AND I.index_id = U.index_id
WHERE	I.object_id = OBJECT_ID(@Tabela)
and		DB_NAME(database_id) = 'TopManager'

Select 'Auxiliares - Reconstrução de Índices ( ' + @Tabela + ' )'
Select	'DBCC SHOWCONTIG (''' + obj.name + ''',''' + idx.name + ''');'
From	sys.indexes idx
join	sys.objects obj on obj.object_id = idx.object_id
Where	obj.name = @Tabela

Select	'ALTER INDEX ' + idx.name + ' ON ' + obj.name + ' REBUILD --WITH (ONLINE = ON);'
From	sys.indexes idx
join	sys.objects obj on obj.object_id = idx.object_id
Where	obj.name = @Tabela

Select ' Indexes_Identifica os indices que precisam ser criados para a Tabela: ' + @Tabela
SELECT	index_advantage AS Advantage -- Vantagem percentual para as queries que precisaram destes índices. Na linha 1, a vantagem é de (718 + 100) / 100, 818%.
,		mid.object_id AS ID
,		mid.Statement AS TableStatement -- TableStatement é composto por nome do banco + owner+ tabela
,		mid.Equality_columns AS Equality -- Colunas que aparecem em equality, representam as colunas onde o filtro foi feito com operadores de igualdade ( =, is)
,		mid.inequality_columns AS Inequality -- As colunas que aparecem em inequality, representam as colunas onde o filtro foi feito com outros operadores ( <> , >, <, etc...)
,		included_columns AS Included -- Included são as colunas que serão facilmente plotadas pelo índice, pois participarão da folha na árvore B.
,		mig.index_handle AS Handler
FROM(
	SELECT (user_seeks + user_scans) * avg_total_user_cost * (avg_user_impact * 0.01) AS index_advantage, migs.* 
		FROM sys.dm_db_missing_index_group_stats migs 
	) AS migs_adv, 
   sys.dm_db_missing_index_groups mig, 
   sys.dm_db_missing_index_details mid 
WHERE	migs_adv.group_handle = mig.index_group_handle 
and		mig.index_handle = mid.index_handle
and		index_advantage > 0
and	mid.Statement = '[TopManager].[dbo].' + @Tabela
ORDER BY 
		index_advantage DESC

Select 'Informações de uma tabela'
exec sp_help @Tabela

--sp_helpconstraint TbPes

--UPDATE STATISTICS [dbo].[TbPes]