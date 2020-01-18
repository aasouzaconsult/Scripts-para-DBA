-- Aqui encontramos:
-- 1. Fragmentação de Índices
-- 2. Contadores de I/O de Índices
-- 3. Indicação de Criação de Índices

------------------------------
-- FRAGMENTAÇÃO DOS ÍNDICES --
------------------------------
--http://msdn.microsoft.com/pt-br/library/ms188917.aspx

--DROP TABLE AnaliseInstancia..Indices

SELECT	TipoIndice = dt.index_type_desc
,		TipoAlocacao = dt.alloc_unit_type_desc 
,		[FillFactor] = si.fill_factor
,		Tabela = OBJECT_NAME(dt.object_id)
,		Indice = si.name
,		Fragmentacao = dt.avg_fragmentation_in_percent
,		Comando = case	when dt.avg_fragmentation_in_percent < 30.0 
							then 'ALTER INDEX ' + si.name + ' ON ' + OBJECT_NAME(dt.object_id) + ' REORGANIZE;'
						when dt.avg_fragmentation_in_percent >= 30.0
							then 'ALTER INDEX ' + si.name + ' ON ' + OBJECT_NAME(dt.object_id) + ' REBUILD;'
				  Else 'Teste' End
Into	AnaliseInstancia..Indices
FROM	sys.dm_db_index_physical_stats (DB_ID(N'TopManager') --, OBJECT_ID(N'Alunos')
, NULL, NULL, NULL, 'DETAILED') dt
JOIN	sys.indexes si ON si.object_id = dt.object_ID AND si.index_id = dt.index_id
WHERE	dt.index_id <> 0
and		dt.avg_fragmentation_in_percent > 10.0
Order	by
		dt.avg_fragmentation_in_percent desc


--------------------------------------------------------------
Select	Comando = 'ALTER INDEX ALL ON ' + Tabela + ' REBUILD;'
,		[%] = Max(Fragmentacao)
From	AnaliseInstancia..Indices
Where	Fragmentacao >= 30
Group by
		Tabela
Order by
		Max(Fragmentacao) desc

--------------------
-- ÍNDICES REGINA --
--------------------
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
WHERE	DB_NAME(database_id) = 'TopManager'
and     I.Name like '%REGINA%'
Order by U.User_Seeks


-------------------------------
-- Contadores de E/S Indices --
-------------------------------
--http://msdn.microsoft.com/pt-br/library/ms174281.aspx

SELECT	Tabela = OBJECT_NAME(dt.object_id)
,		Indice = si.name
,		dt.leaf_insert_count -- Contagem cumulativa de inserções de nível folha.
,		dt.leaf_delete_count -- Contagem cumulativa de exclusões de nível folha.
,		dt.leaf_update_count -- Contagem cumulativa de atualizações de nível folha. 
,		dt.leaf_ghost_count  -- Contagem cumulativa de linhas de nível folha marcadas como excluídas, mas não removidas ainda. Essas filas são removidas por um thread de limpeza em intervalos definidos.
,		dt.range_scan_count  -- Contagem cumulativa de exames de intervalo e tabela iniciados no índice ou heap.
,		dt.singleton_lookup_count -- Contagem cumulativa de recuperações de linha única do índice ou heap. 
-- Para identificar a contenção de bloqueio e trava, use estas colunas:
,		dt.page_latch_wait_count -- Número cumulativo de vezes que o Mecanismo de Banco de Dados esperou devido a uma contenção de travamento.
,		dt.page_latch_wait_in_ms -- Número cumulativo de milissegundos que o Mecanismo de Banco de Dados esperou devido a uma contenção de travamento.
,		dt.row_lock_count		 -- Número cumulativo de bloqueios solicitados. 
,		dt.page_lock_count		 -- Número cumulativo de bloqueios de página solicitados.
,		dt.row_lock_wait_in_ms   -- Número total de milissegundos que o Mecanismo de Banco de Dados esperou por um bloqueio de linha. 
,		dt.page_lock_wait_in_ms  -- Número total de milissegundos que o Mecanismo de Banco de Dados esperou por um bloqueio de página.
-- Para analisar estatísticas de E/S física em uma partição de índice ou de heap
,		dt.page_io_latch_wait_count -- Número cumulativo de vezes que o Mecanismo de Banco de Dados esperou em um travamento de página de E/S.
,		dt.page_io_latch_wait_in_ms -- Número cumulativo de milissegundos que o Mecanismo de Banco de Dados esperou em uma trava de E/S de página.
FROM	sys.dm_db_index_operational_stats(13, NULL, NULL, NULL) dt
JOIN	sys.indexes si ON si.object_id = dt.object_ID AND si.index_id = dt.index_id
Order by
--		OBJECT_NAME(dt.object_id); -- Tabela
--		dt.leaf_insert_count desc -- Contagem cumulativa de inserções de nível folha.
--		dt.leaf_delete_count desc -- Contagem cumulativa de exclusões de nível folha.
--		dt.leaf_update_count desc -- Contagem cumulativa de atualizações de nível folha. 
--		dt.leaf_ghost_count desc -- Contagem cumulativa de linhas de nível folha marcadas como excluídas, mas não removidas ainda. Essas filas são removidas por um thread de limpeza em intervalos definidos.
--		dt.range_scan_count desc -- Contagem cumulativa de exames de intervalo e tabela iniciados no índice ou heap.
--		dt.singleton_lookup_count desc -- Contagem cumulativa de recuperações de linha única do índice ou heap. 
--		dt.page_latch_wait_count desc -- Número cumulativo de vezes que o Mecanismo de Banco de Dados esperou devido a uma contenção de travamento.
--		dt.page_latch_wait_in_ms desc -- Número cumulativo de milissegundos que o Mecanismo de Banco de Dados esperou devido a uma contenção de travamento.
		dt.row_lock_count desc		 -- Número cumulativo de bloqueios solicitados. 
--		dt.page_lock_count desc		 -- Número cumulativo de bloqueios de página solicitados.
--		dt.row_lock_wait_in_ms desc  -- Número total de milissegundos que o Mecanismo de Banco de Dados esperou por um bloqueio de linha. 
--		dt.page_lock_wait_in_ms desc -- Número total de milissegundos que o Mecanismo de Banco de Dados esperou por um bloqueio de página.
--		dt.page_io_latch_wait_count desc -- Número cumulativo de vezes que o Mecanismo de Banco de Dados esperou em um travamento de página de E/S.
--		dt.page_io_latch_wait_in_ms desc -- Número cumulativo de milissegundos que o Mecanismo de Banco de Dados esperou em uma trava de E/S de página.


--------------------------------------
-- INDICAÇÃO DE CRIAÇÃO DE ÍNDICES) --
--------------------------------------

-- Identificando ausência de índices (Identifica os Índices que possívelmente devam ser criados)
---> O SQL Server 2005 guarda informação sobre os índices que foram necessários mas não foram encontrados. (DMF)
---> Estas informações podem ser acessadas através das views:
----> sys.dm_db_missing_index_group_stats
----> sys.dm_db_missing_index_groups
----> sys.dm_db_missing_index_details

---> 1. indexes_Identifica os indices que precisam ser criados

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
--and	mid.Statement = '[TopManager].[dbo].[TbRcd]'
ORDER BY 
		migs_adv.index_advantage DESC

/*	Para criar indices com estas informações, basta usar:
	- TableStatement como a tabela onde o índice deve ser criado
	- Equality e Inequality como as colunas onde o índice deve ser criado
	- Included como as colunas que devem estar incluídas no índice. */

--> Monta as Querys para a criação dos Índices
---> 2. indexes_Monta as querys de criaçao dos indices

DECLARE @MIN_INDEX_ADVANTAGE AS INT
DECLARE @Advantage AS NUMERIC(20,3)
DECLARE @ID AS INT
DECLARE @TableStatement AS VARCHAR(80)
DECLARE @Equality AS VARCHAR(1000)
DECLARE @Inequality AS VARCHAR(1000)
DECLARE @Included AS VARCHAR (8000)
DECLARE @Handler AS INT

SET		@MIN_INDEX_ADVANTAGE = 0

DECLARE MissingIndexes CURSOR FOR
SELECT index_advantage AS Advantage, mid.object_id AS ID, mid.Statement AS TableStatement, mid.Equality_columns AS Equality, mid.inequality_columns AS Inequality, included_columns AS Included, mig.index_handle AS Handler 
FROM(
	SELECT (user_seeks + user_scans) * avg_total_user_cost * (avg_user_impact * 0.01) AS index_advantage, migs.* 
		FROM sys.dm_db_missing_index_group_stats migs 
	) AS migs_adv, 
   sys.dm_db_missing_index_groups mig, 
   sys.dm_db_missing_index_details mid 
WHERE 
   migs_adv.group_handle = mig.index_group_handle and 
   mig.index_handle = mid.index_handle and
   index_advantage > @MIN_INDEX_ADVANTAGE
   --and	mid.Statement = '[TopManager].[dbo].[TbRcd]'
ORDER BY migs_adv.index_advantage DESC 

OPEN MissingIndexes
FETCH NEXT FROM MissingIndexes 
INTO @Advantage, @ID, @TableStatement, @Equality, @Inequality, @Included, @Handler

WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE @Columns AS Varchar(2000)
	SET @Columns = ''

	IF @Equality IS NOT NULL SET @Columns = @Columns + @Equality
	IF @Inequality IS NOT NULL AND @Equality IS NOT NULL SET @Columns = @Columns + ', ' + @Inequality
	IF @Inequality IS NOT NULL AND @Equality IS NULL SET @Columns = @Inequality

	IF @Included IS NULL
		print('/* ' + CONVERT(VARCHAR(14), @Advantage) + '% */ CREATE INDEX I_REGINA_' + convert(varchar(8), @Handler)) + ' ON ' + @TableStatement + ' (' + @Columns + ')'
	ELSE
		print('/* ' + CONVERT(VARCHAR(14), @Advantage) + '% */ CREATE INDEX I_REGINA_' + convert(varchar(8), @Handler)) + ' ON ' + @TableStatement + ' (' + @Columns + ') INCLUDE (' + @Included + ')'

	FETCH NEXT FROM MissingIndexes 
	INTO @Advantage, @ID, @TableStatement, @Equality, @Inequality, @Included, @Handler
END

CLOSE MissingIndexes
DEALLOCATE MissingIndexes

-- Mostra os índices que estão criados
---> 3. Indexes_Mostra os indices que estao criados
DECLARE @table_object_id AS int
DECLARE @index_id AS int
DECLARE @index_name AS varchar(60)
DECLARE @table_name AS varchar(30)
DECLARE @clause AS varchar(30)
DECLARE @column_id AS int
DECLARE @is_included_column AS bit
DECLARE @TABLE_TO_SEARCH AS Varchar(30)
SET @TABLE_TO_SEARCH = ''

IF @TABLE_TO_SEARCH = '' SET @TABLE_TO_SEARCH = '%%'
DECLARE indexes CURSOR FOR 
	SELECT		sys.indexes.object_id, sys.indexes.name, index_id 
	FROM		sys.indexes 
	INNER JOIN	sys.objects on sys.objects.object_id = sys.indexes.object_id
	WHERE		sys.indexes.Object_id > 100 and sys.objects.name like @TABLE_TO_SEARCH

OPEN indexes
FETCH NEXT FROM indexes 
INTO @table_object_id, @index_name, @index_id

WHILE @@FETCH_STATUS = 0
BEGIN
      SELECT @table_name = name FROM sys.objects 
            WHERE object_id = @table_object_id
      DECLARE index_columns CURSOR FOR
            SELECT column_id, is_included_column FROM sys.index_columns 
            WHERE sys.index_columns.object_id= @table_object_id
                  AND sys.index_columns.index_id = @index_id
            ORDER BY index_column_id
      print '---------------'
      print 'Nome da tabela: ' + @table_name
      print 'Nome do índice: ' + @index_name
      print 'ID do índice: ' + convert(varchar(3),@index_id)
      print 'Colunas do índice: ' 
      OPEN index_columns

      FETCH NEXT FROM index_columns 

      INTO @column_id, @is_included_column

            WHILE @@FETCH_STATUS = 0
            BEGIN
                  DECLARE @column_name AS varchar(30)
                  SELECT @column_name = name FROM sys.columns 
                        WHERE object_id = @table_object_id
                        AND column_id = @column_id
                  IF @is_included_column = 0 print @column_name
                  ELSE print '(included)' +@column_name 
                  FETCH NEXT FROM index_columns 
                  INTO @column_id, @is_included_column
            END;
      CLOSE index_columns

      DEALLOCATE index_columns
      FETCH NEXT FROM indexes 
      INTO @table_object_id, @index_name, @index_id
END

CLOSE indexes
DEALLOCATE indexes

-----------
-- NOVOS --
-----------

-- When were Statistics last updated on all indexes?  (Query 59) (Statistics Update)
SELECT SCHEMA_NAME(o.Schema_ID) + N'.' + o.NAME AS [Object Name], o.type_desc AS [Object Type],
      i.name AS [Index Name], STATS_DATE(i.[object_id], i.index_id) AS [Statistics Date], 
      s.auto_created, s.no_recompute, s.user_created, st.row_count, st.used_page_count
FROM sys.objects AS o WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON o.[object_id] = i.[object_id]
INNER JOIN sys.stats AS s WITH (NOLOCK)
ON i.[object_id] = s.[object_id] 
AND i.index_id = s.stats_id
INNER JOIN sys.dm_db_partition_stats AS st WITH (NOLOCK)
ON o.[object_id] = st.[object_id]
AND i.[index_id] = st.[index_id]
WHERE o.[type] IN ('U', 'V')
AND st.row_count > 0
ORDER BY STATS_DATE(i.[object_id], i.index_id) DESC OPTION (RECOMPILE);  

-- Helps discover possible problems with out-of-date statistics
-- Also gives you an idea which indexes are the most active


-- Look at most frequently modified indexes and statistics (Query 60) (Volatile Indexes)
-- Requires SQL Server 2008 R2 SP2 or newer
SELECT o.name AS [Object Name], o.[object_id], o.type_desc, s.name AS [Statistics Name], 
       s.stats_id, s.no_recompute, s.auto_created, 
	   sp.modification_counter, sp.rows, sp.rows_sampled, sp.last_updated
FROM sys.objects AS o WITH (NOLOCK)
INNER JOIN sys.stats AS s WITH (NOLOCK)
ON s.object_id = o.object_id
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) AS sp
WHERE o.type_desc NOT IN (N'SYSTEM_TABLE', N'INTERNAL_TABLE')
AND sp.modification_counter > 0
ORDER BY sp.modification_counter DESC, o.name OPTION (RECOMPILE);


-- Get fragmentation info for all indexes above a certain size in the current database  (Query 61) (Index Fragmentation)
-- Note: This query could take some time on a very large database
SELECT DB_NAME(ps.database_id) AS [Database Name], OBJECT_NAME(ps.OBJECT_ID) AS [Object Name], 
i.name AS [Index Name], ps.index_id, ps.index_type_desc, ps.avg_fragmentation_in_percent, 
ps.fragment_count, ps.page_count, i.fill_factor, i.has_filter, i.filter_definition
FROM sys.dm_db_index_physical_stats(DB_ID(),NULL, NULL, NULL , N'LIMITED') AS ps
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON ps.[object_id] = i.[object_id] 
AND ps.index_id = i.index_id
WHERE ps.database_id = DB_ID()
AND ps.page_count > 2500
ORDER BY ps.avg_fragmentation_in_percent DESC OPTION (RECOMPILE);

-- Helps determine whether you have framentation in your relational indexes
-- and how effective your index maintenance strategy is


--- Index Read/Write stats (all tables in current DB) ordered by Reads  (Query 62) (Overall Index Usage - Reads)
SELECT OBJECT_NAME(s.[object_id]) AS [ObjectName], i.name AS [IndexName], i.index_id,
	   user_seeks + user_scans + user_lookups AS [Reads], s.user_updates AS [Writes],  
	   i.type_desc AS [IndexType], i.fill_factor AS [FillFactor], i.has_filter, i.filter_definition, 
	   s.last_user_scan, s.last_user_lookup, s.last_user_seek
FROM sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON s.[object_id] = i.[object_id]
WHERE OBJECTPROPERTY(s.[object_id],'IsUserTable') = 1
AND i.index_id = s.index_id
AND s.database_id = DB_ID()
ORDER BY user_seeks + user_scans + user_lookups DESC OPTION (RECOMPILE); -- Order by reads


-- Show which indexes in the current database are most active for Reads


--- Index Read/Write stats (all tables in current DB) ordered by Writes  (Query 63) (Overall Index Usage - Writes)
SELECT OBJECT_NAME(s.[object_id]) AS [ObjectName], i.name AS [IndexName], i.index_id,
	   s.user_updates AS [Writes], user_seeks + user_scans + user_lookups AS [Reads], 
	   i.type_desc AS [IndexType], i.fill_factor AS [FillFactor], i.has_filter, i.filter_definition,
	   s.last_system_update, s.last_user_update
FROM sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON s.[object_id] = i.[object_id]
WHERE OBJECTPROPERTY(s.[object_id],'IsUserTable') = 1
AND i.index_id = s.index_id
AND s.database_id = DB_ID()
ORDER BY s.user_updates DESC OPTION (RECOMPILE);						 -- Order by writes

-- Show which indexes in the current database are most active for Writes


-- Get lock waits for current database (Query 64) (Lock Waits)
SELECT o.name AS [table_name], i.name AS [index_name], ios.index_id, ios.partition_number,
		SUM(ios.row_lock_wait_count) AS [total_row_lock_waits], 
		SUM(ios.row_lock_wait_in_ms) AS [total_row_lock_wait_in_ms],
		SUM(ios.page_lock_wait_count) AS [total_page_lock_waits],
		SUM(ios.page_lock_wait_in_ms) AS [total_page_lock_wait_in_ms],
		SUM(ios.page_lock_wait_in_ms)+ SUM(row_lock_wait_in_ms) AS [total_lock_wait_in_ms]
FROM sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) AS ios
INNER JOIN sys.objects AS o WITH (NOLOCK)
ON ios.[object_id] = o.[object_id]
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON ios.[object_id] = i.[object_id] 
AND ios.index_id = i.index_id
WHERE o.[object_id] > 100
GROUP BY o.name, i.name, ios.index_id, ios.partition_number
HAVING SUM(ios.page_lock_wait_in_ms)+ SUM(row_lock_wait_in_ms) > 0
ORDER BY total_lock_wait_in_ms DESC OPTION (RECOMPILE);
