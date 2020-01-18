	-- 1. Processos Travados -- http://www.dpriver.com/pp/sqlformat.htm
-- http://msdn.microsoft.com/pt-br/library/ms189497.aspx

-- Armazem de locks
--SELECT * from AnaliseInstancia..MonitoraLocks
--Where Data_hora >= '20130501'
--Order by [data_hora] desc

-- Máquinas que acessaram...
SELECT distinct hostname
  FROM [AnaliseInstancia].[dbo].[UsuariosLogados_SSMS]
 WHERE DATA >= '20130122'
 -- WHERE hostname = 'PC4133'
 -- Order by [data] desc

--sp_lock 2685
--kill 201

-- Processos travados
EXEC AnaliseInstancia.[dbo].[stpVerifica_ProcessosTravados]
SELECT [Tempo(ms)]         = WaitMsQTy
     , [Data/Hora]         = getdate()
     , Processo            = CallingSpId
     , [SQL do Processo]   = CallingSQL
     , CallingResourceType
     , CallingRequestMode
     , [Bloqueado por]     = BlockingSpId
     , [SQL Bloqueado por] = BlockingSQL
     , BlockingResourceType
     , BlockingRequestMode
  FROM AnaliseInstancia..vw_dba_locks;

-- Usuário utilizando nos BDs atraves do SSMS
-- SELECT * FROM [AnaliseInstancia].[dbo].[UsuariosLogados_SSMS] ORDER BY DATA DESC
-- SELECT DISTINCT hostname FROM [AnaliseInstancia]..UsuariosLogados_SSMS
SELECT loginame
     , spid
     , hostname
     , program_name
     , comando = 'kill ' + convert(varchar,spid) + ' -- ' + hostname
  FROM master..sysprocesses 
 WHERE program_name <> '.Net SqlClient Data Provider'
   AND   loginame <> 'Guberman'
 ORDER BY loginame
  
SELECT  blocking.session_id AS blocking_session_id ,
	    blocked.session_id AS blocked_session_id ,
	    waitstats.wait_type AS blocking_resource ,
	    waitstats.wait_duration_ms ,
	    waitstats.resource_description ,
	    blocked_cache.text AS blocked_text ,
	    blocking_cache.text AS blocking_text
  FROM        sys.dm_exec_connections AS blocking
  INNER JOIN  sys.dm_exec_requests blocked ON blocking.session_id = blocked.blocking_session_id
  CROSS APPLY sys.dm_exec_sql_text(blocked.sql_handle) blocked_cache
  CROSS APPLY sys.dm_exec_sql_text(blocking.most_recent_sql_handle)	blocking_cache
  INNER JOIN sys.dm_os_waiting_tasks waitstats ON waitstats.session_id = blocked.session_id
		
  --EXEC sp_whoisactive  @get_locks = 1, @find_block_leaders = 1 -- exec sp_whoisactive @help=1
   -- @show_sleeping_spids = 0
   -- @get_plans = 1
   -- @get_outer_command = 1
   -- @get_locks = 1
   -- @find_block_leaders = 1
   -- @sort_order = 'session_id'
  
-- KILL 66 WITH STATUSONLY

-- Paginas corrompidas
SELECT * FROM msdb..Suspect_pages

-- Sessões abertas
SELECT login_name, COUNT(session_id) AS [session_count] 
FROM sys.dm_exec_sessions WITH (NOLOCK)
WHERE session_id > 50	-- filter out system SPIDs
GROUP BY login_name
ORDER BY COUNT(session_id) DESC OPTION (RECOMPILE);

-- Trabalhos em execução
SELECT max_workers_count, * From sys.dm_os_sys_info
SELECT Threads = count(*) From sys.dm_os_threads --(857, 855, 856, 854, 865, 586, 644, 551, 881, 882, 661, 656, 638, 639, 632, 611, 603, 563, 
                                                 -- 883)
-- max_workes_count >= Threads (o ideal)

-- Verifica Tempo restante de Backup /restore
--  Funciona no SQLSEVER 2005, 2008 e 2008 R2
SELECT start_time
     , (total_elapsed_time/1000/60) AS MinutesRunning
     , percent_complete
     , command
     , b.name AS DatabaseName
     , DATEADD(ms,estimated_completion_time,GETDATE()) AS StimatedCompletionTime
     , (estimated_completion_time/1000/60) AS MinutesToFinish
  FROM       sys.dm_exec_requests a
  INNER JOIN sys.DATABASES        b ON a.database_id = b.database_id
 WHERE command LIKE '%restore%' OR command LIKE '%backup%' AND estimated_completion_time > 0
 

-- Memória alocada durante o backup
SELECT *
FROM sys.dm_os_memory_clerks WHERE type = 'MEMORYCLERK_SQLUTILITIES' -- MEMORYCLERK_SQLUTILITIES
 
 
 
-- Backups FULL (Familia de Backup)
SELECT a.type
     , physical_device_name
     , backup_start_date
     , backup_finish_date
FROM       msdb.dbo.backupset         a
INNER JOIN msdb.dbo.backupmediafamily b ON a.media_set_id = b.media_set_id
WHERE /*database_name = 'NOME_DO_BANCO' and */ a.type = 'D'
ORDER BY backup_start_date desc

-- Retorna informações sobre transações no nível do banco de dados (http://msdn.microsoft.com/pt-br/library/ms186957.aspx)
SELECT	db.name
,		trans.transaction_id
,		Tipo = Case when trans.database_transaction_type = 1 Then 'Transação de leitura/gravação'
					when trans.database_transaction_type = 2 Then 'Transação somente leitura'
					when trans.database_transaction_type = 3 Then 'Transação de sistema'
			   Else 'Não classificado' End	
,		trans.database_transaction_begin_time -- Hora na qual o banco de dados foi envolvido na transação. Especificamente, é a hora do primeiro registro de log no banco de dados da transação.
,		Estado = Case	when trans.database_transaction_state = 1  Then 'A transação não foi inicializada.'
						when trans.database_transaction_state = 3  Then 'A transação foi inicializada mas não gerou registros de log.'
						when trans.database_transaction_state = 4  Then 'A transação gerou registros de log.'
						when trans.database_transaction_state = 5  Then 'A transação foi preparada.'
						when trans.database_transaction_state = 10 Then 'A transação foi confirmada.'
						when trans.database_transaction_state = 11 Then 'A transação foi revertida.'
						when trans.database_transaction_state = 12 Then 'A transação está sendo confirmada. Neste estado está sendo gerado o registro de log, mas ele não foi materializado nem persistiu.'
				 Else 'Não classificado' End
,		trans.database_transaction_log_record_count -- Número de registros de log gerados no banco de dados para a transação
,		trans.database_transaction_log_bytes_used --Número de bytes usados até o momento no log do banco de dados para a transação.
,		trans.database_transaction_log_bytes_reserved -- Número de bytes reservados para uso no log do banco de dados para a transação.
,		comando = st.text
From	sys.dm_tran_database_transactions trans
JOIN	sys.databases db on db.database_id = trans.database_id
JOIN	sys.dm_exec_requests rec on rec.transaction_id = trans.transaction_id -- Em execução
cross apply sys.dm_exec_sql_text(rec.sql_handle) as st
Order by
		db.name


-- I/O
--SELECT * FROM sys.dm_io_virtual_file_stats(DB_ID(N'AdventureWorks2008R2'), 2);
SELECT	db.name
,		vfs.*  
FROM	sys.dm_io_virtual_file_stats(NULL, NULL) vfs -- http://msdn.microsoft.com/pt-br/library/ms190326.aspx
JOIN	sys.databases db on db.database_id = vfs.database_id

SELECT * from sys.dm_io_backup_tapes

--E/S pendentes (http://msdn.microsoft.com/pt-br/library/ms188762.aspx)
SELECT * From sys.dm_io_pending_io_requests

-- Contadores de Desempenho
SELECT * from sys.dm_os_performance_counters

-- 2. Retorna as 10 Querys com maior tempo de execução 
SELECT  Top 10
		creation_time
,		last_execution_time
,		total_clr_time
,		total_clr_time / execution_count as [Avg CLR Time]
,		last_clr_time
,		execution_count
,		Substring (st.text, (qs.statement_start_offset / 2) + 1,
		((Case statement_end_offset
			when -1 then datalength(st.text)
			else qs.statement_end_offset 
			end -qs.statement_start_offset)/2) + 1) as Query
From	sys.dm_exec_query_stats as qs
cross apply sys.dm_exec_sql_text(qs.sql_handle) as st
Order by
		total_clr_time / execution_count desc

-- 3. Retorna a Média das 10 Query's que mais consumiram tempo de CPU
SELECT Top 10
		total_worker_time / execution_count as [Avg CPU Time]
,		Substring (st.text, (qs.statement_start_offset / 2) + 1,
		((Case statement_end_offset
			when -1 then datalength(st.text)
			else qs.statement_end_offset 
			end	-qs.statement_start_offset)/2) + 1) as Query		
From	sys.dm_exec_query_stats as qs
cross apply sys.dm_exec_sql_text(qs.sql_handle) as st
Order by
		total_worker_time / execution_count desc

-- 4. Verificar qual o database mais utilizado na instância
SELECT 
    COUNT(*) AS cached_pages_count,
    CASE database_id 
    WHEN 32767 THEN 'ResourceDb' 
    ELSE DB_NAME(database_id) 
    END AS Database_name
FROM 
    sys.dm_os_buffer_descriptors
GROUP BY 
    DB_NAME(database_id),
    database_id
ORDER BY 
    cached_pages_count DESC;

-- 5. Determinando a quantidade de espaço livre em tempdb
SELECT SUM(unallocated_extent_page_count) AS [free pages], 
(SUM(unallocated_extent_page_count)*1.0/128) AS [free space in MB]
FROM sys.dm_db_file_space_usage

-- 5.1. Conexões que ocupam mais espaço no TempDB
SELECT		A.session_id
,			B.host_name
,			B.Login_Name
,			(user_objects_alloc_page_count + internal_objects_alloc_page_count)*1.0/128 as TotalalocadoMB
,			D.Text
FROM		sys.dm_db_session_space_usage A
JOIN		sys.dm_exec_sessions B  ON A.session_id = B.session_id
JOIN		sys.dm_exec_connections C ON C.session_id = B.session_id
CROSS APPLY sys.dm_exec_sql_text(C.most_recent_sql_handle) As D
WHERE		
			A.session_id > 50
and			(user_objects_alloc_page_count + internal_objects_alloc_page_count)*1.0/128 > 100 -- Ocupam mais de 100 MB
ORDER BY 
			totalalocadoMB desc
COMPUTE 
			sum((user_objects_alloc_page_count + internal_objects_alloc_page_count)*1.0/128)

-- 6. Número de Linhas por tabela no database
SELECT	o.name AS "Nome da Tabela"
,		i.rowcnt AS "Total de Linhas"
FROM	sysobjects o, sysindexes i WHERE i.id = o.id
AND		indid IN(0,1) AND o.name <> 'sysdiagrams' AND o.xtype = 'U'
Order by
		i.rowcnt desc

-- 7. indexes_Identifica os indices que precisam ser criados
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
		index_advantage DESC

-- 8. indexes_Monta as querys de criaçao dos indices
DECLARE @MIN_INDEX_ADVANTAGE AS INT
DECLARE @Advantage AS NUMERIC(10,3)
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
   and	mid.Statement = '[TopManager].[dbo].[TbRcd]'
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

-- ************************************************
-- * Consulta a utilização dos índices por tabela *
-- ************************************************
SELECT		DB_NAME(database_id) As Banco
,			OBJECT_NAME(I.object_id) As Tabela
,			I.Name As Indice
,			U.User_Seeks As Pesquisas	-- Número de buscas através de consultas de usuário. 
,			U.User_Scans As Varreduras	-- Número de exames através de consultas de usuário. 
,			U.User_Lookups As LookUps	-- Número de pesquisas de indicador através de consultas de usuário.
,			U.User_updates AS Updates
,			U.Last_User_Seek As UltimaPesquisa
,			U.Last_User_Scan As UltimaVarredura
,			U.Last_User_LookUp As UltimoLookUp
,			U.Last_User_Update As UltimaAtualizacao
FROM		sys.indexes As I
LEFT JOIN	sys.dm_db_index_usage_stats As U ON I.object_id = U.object_id AND I.index_id = U.index_id
JOIN		sys.objects As Obj ON Obj.object_id = I.object_id
WHERE	DB_NAME(database_id) = 'TopManager'
--and		I.object_id = OBJECT_ID('TbFfm')
--and		U.User_Seeks < 10 -- Somente com menos de 10
--and		U.User_Scans < 10 -- Somente com menos de 10
--and		U.User_Lookups < 10 -- Somente com menos de 10

-- **************************************************************
-- Informações de índices (Clustered, nonclusteres, unicos e etc)
-- **************************************************************
SELECT	o.name
,		i.name
,		i.type_desc 
From	sys.indexes i
join	sys.objects o on o.object_id = i.object_id
Where	i.type = 2 --(0 - HEAP; 1 - CLUSTERED; 2 - NONCLUSTERED)
and		i.object_id > 100
--and	is_unique = 1 -- (INDICES UNICOS)
and		i.is_unique = 0 -- (NÃO UNICOS)
Order by
		o.name

-- **********************************************
-- * Quantidade de Indices e Colunas por Tabela *
-- **********************************************
SELECT	Tabela = o.name
,		[Qtd de Indices] = Count(o.name)
,		[Qtd de Colunas] = (SELECT count(*) From sys.columns Where object_id = o.object_id)
From	sys.indexes i
join	sys.objects o on o.object_id = i.object_id and o.type = 'U'
Group by
		o.name
,		o.object_id
-- Mostra em quais tabelas existem mais indices do que colunas na tabela
--having Count(o.name) > (SELECT count(*) From sys.columns Where object_id = o.object_id)
Order by
		Count(o.name) desc


-- **************************
-- * ÍNDICES NÃO UTILIZADOS *
-- **************************
/* Parte(A) identifica índices sem entrada na DMV 'dm_db_index_usage_stats', isto indica que o índice nunca foi utilizado desde a inicialização do SQL Server */
SELECT DB_NAME(), OBJECT_NAME(i.object_id) AS 'Table', ISNULL(i.name, 'heap') AS 'Index', x.used_page_count AS 'SizeKB'
FROM sys.objects o
INNER JOIN sys.indexes i
ON i.[object_id] = o.[object_id]
LEFT JOIN sys.dm_db_index_usage_stats s
ON i.index_id = s.index_id and s.object_id = i.object_id
LEFT JOIN sys.dm_db_partition_stats x
ON i.[object_id] = x.[object_id] AND i.index_id = x.index_id
WHERE OBJECT_NAME(o.object_id) IS NOT NULL AND OBJECT_NAME(s.object_id) IS NULL
AND o.[type] = 'U' AND ISNULL(i.name, 'heap') <> 'heap'

UNION ALL

/* Parte(B) identifica índices que não são mais utilizados desde a inicialização da instância do SQL Server */
SELECT DB_NAME(), OBJECT_NAME(i.object_id) AS 'Table', ISNULL(i.name, 'heap') AS 'Index', x.used_page_count AS 'SizeKB'
FROM sys.objects o
INNER JOIN sys.indexes i
ON i.[object_id] = o.[object_id]
LEFT JOIN sys.dm_db_index_usage_stats s
ON i.index_id = s.index_id and s.object_id = i.object_id
LEFT JOIN sys.dm_db_partition_stats x
ON i.[object_id] = x.[object_id] AND i.index_id = x.index_id
WHERE user_seeks = 0 AND user_scans = 0 AND user_lookups = 0
AND o.[type] = 'U' AND ISNULL(i.name, 'heap') <> 'heap'
ORDER BY 2 ASC

-- **************************************
-- Espaço utilizado por tabelas e índices
-- **************************************
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


-- **********************
-- **** Fragmentação ****
-- **********************
--http://msdn.microsoft.com/pt-br/library/ms188917.aspx

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
Into	#TempIndex
FROM	sys.dm_db_index_physical_stats (DB_ID(N'TopManager') --, OBJECT_ID(N'Alunos')
, NULL, NULL, NULL, 'DETAILED') dt
JOIN	sys.indexes si ON si.object_id = dt.object_ID AND si.index_id = dt.index_id
WHERE	dt.index_id <> 0
and		dt.avg_fragmentation_in_percent > 10.0
Order	by
		dt.avg_fragmentation_in_percent desc

--------------------------------------------------------------
SELECT	Comando = 'ALTER INDEX ALL ON ' + Tabela + ' REBUILD;'
,		[%] = Max(Fragmentacao)
From	AnaliseInstancia..Indices
Where	Fragmentacao >= 30
Group by
		Tabela
Order by
		Max(Fragmentacao) desc


--ALTER INDEX I_Lcu ON TbLcu REBUILD;
--DBCC SHOWCONTIG (TbLcu,I_Lcu);

--http://msdn.microsoft.com/pt-br/library/ms174281.aspx

-- *********************************
-- *** Contadores de E/S Indices ***
-- *********************************
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
--		dt.row_lock_count desc		 -- Número cumulativo de bloqueios solicitados. 
		dt.page_lock_count desc		 -- Número cumulativo de bloqueios de página solicitados.
--		dt.row_lock_wait_in_ms desc  -- Número total de milissegundos que o Mecanismo de Banco de Dados esperou por um bloqueio de linha. 
--		dt.page_lock_wait_in_ms desc -- Número total de milissegundos que o Mecanismo de Banco de Dados esperou por um bloqueio de página.
--		dt.page_io_latch_wait_count desc -- Número cumulativo de vezes que o Mecanismo de Banco de Dados esperou em um travamento de página de E/S.
--		dt.page_io_latch_wait_in_ms desc -- Número cumulativo de milissegundos que o Mecanismo de Banco de Dados esperou em uma trava de E/S de página.

-- Conexões ao SQL Server - Mostra IP
SELECT  ec.client_net_address,
	es.[program_name],
	es.[host_name],
	es.login_name
FROM sys.dm_exec_sessions AS es 
INNER JOIN sys.dm_exec_connections AS ec ON es.session_id = ec.session_id
ORDER BY ec.client_net_address,  es.[program_name];



--****************** OUTRAS ******************
--
--USE AnaliseInstancia
---- ****************
---- Espaço em Disco:
---- ****************
--Exec AnaliseInstancia.dbo.stpVerifica_Espaco_Disco
--GO
--SELECT	[Drive]
--,		[Tamanho (MB)]
--,		[Usado (MB)]
--,		[Livre (MB)]
--,		[Livre (GB)] = [Livre (MB)] / 1024
--,		[Livre (%)]
--,		[Usado (%)]
--,		[Ocupado SQL (MB)]
--,		[Ocupado SQL (GB)] = [Ocupado SQL (MB)] / 1024
--FROM AnaliseInstancia.dbo.EspacoEmDisco
--
---- ******************************
---- Monitoramento dos arquivos SQL
---- ******************************
--Exec AnaliseInstancia.dbo.stpMonitora_ArquivosSQL
--GO
--SELECT	Name
--,		FileName
--,		Size
--,		MaxSize
--,		Growth
--,		Proximo_Tamanho
--,		Situacao
--FROM AnaliseInstancia.dbo.ArquivosSQL order by Name
--
--/* Quando o valor da coluna Tamanho Max(MB) dessa aba da planilha for igual a -1, significa que esse arquivo não possui uma restrição de 
--crescimento.
--Quando a coluna “Situacao” retornar o valor PROBLEMA, significa que o arquivo não conseguirá crescer mais uma vez, logo, esse arquivo de 
--ver diminuído ou ter seu tamanho máximo aumentado para que quando ele precise crescer o SQL Server não gere um erro.*/
--
---- ****************************
---- Utilização do Arquivo de Log
---- ****************************
--Exec StpVerifica_Utilizacao_Log
--GO
--SELECT	Nm_Database
--,		Log_Size
--,		[Log_Space_Used(%)]
--,		status_log		
--From	AnaliseInstancia.dbo.UtilizacaoLog
--
----ou
--SELECT	db.[name] AS [Database Name]
--,		db.recovery_model_desc AS [Recovery Model]
--,		db.log_reuse_wait_desc AS [Log Reuse Wait Description]
--,		CONVERT(DECIMAL (19,2), ls.cntr_value) AS [Log Size (KB)]
--,		lu.cntr_value AS [Log Used (KB)]
--,		CAST(CAST(lu.cntr_value AS FLOAT) / Case when CAST(ls.cntr_value AS FLOAT) = 0 then 1
--											Else CAST(ls.cntr_value AS FLOAT)
--											End	AS DECIMAL(18,2)) * 100 AS [Log Used %]
--,		db.[compatibility_level] AS [DB Compatibility Level]
--,		db.page_verify_option_desc AS [Page Verify Option]
--FROM	sys.databases AS db
--INNER JOIN sys.dm_os_performance_counters AS lu ON db.name = lu.instance_name
--INNER JOIN sys.dm_os_performance_counters AS ls ON db.name = ls.instance_name
--WHERE	lu.counter_name LIKE 'Log File(s) Used Size (KB)%'
--AND		ls.counter_name LIKE 'Log File(s) Size (KB)%' ;
--
--
---- ******
---- Backup
---- ******
--Exec [StpVerifica_Backups]
--GO
--SELECT	database_name
--,		name
--,		backup_start_date
--,		tempo
--,		server_name
--,		recovery_model
--,		tamanho		
--From	AnaliseInstancia.dbo.Backups
--
---- ***************
---- Jobs executando
---- ***************
--exec [StpVerifica_JobsRodando]
--GO
--SELECT * from AnaliseInstancia.dbo.JobsRodando
--
---- *****************
---- Jobs que falharam
---- *****************
--
--
--
---- ######################
---- ##### AUXILIARES #####
---- ######################
--
---- ****************
---- Espaço em Disco:
---- ****************
--sp_configure 'show advanced options',1
--GO
--reconfigure
--GO
--sp_configure 'Ole Automation Procedures',1
--GO
--reconfigure
--GO
--sp_configure 'show advanced options',0
--GO
--reconfigure
--
--
--sp_configure
--
----Após habilitada, devemos criar a procedure abaixo em uma determinada database. Segue o script da procedure:
--CREATE DATABASE AnaliseInstancia
--
--Use	AnaliseInstancia
--
--CREATE PROCEDURE [dbo].[stpVerifica_Espaco_Disco]
--AS
--BEGIN
--	SET NOCOUNT ON
--	CREATE TABLE #dbspace (name sysname, caminho varchar(200),tamanho varchar(10), drive Varchar(30))
--	
--	CREATE TABLE [#espacodisco] (    Drive varchar (10) ,[Tamanho (MB)] Int, [Usado (MB)] Int,
--	[Livre (MB)] Int, [Livre (%)] int, [Usado (%)] int, [Ocupado SQL (MB)] Int,[Data] smalldatetime)
--	
--	Exec SP_MSForEachDB 'Use ? Insert into #dbspace SELECT Convert(Varchar(25),DB_Name())"Database",Convert(Varchar(60),FileName),Convert(Varchar(8),Size/128)"Size in MB",Convert(Varchar(30),Name) from SysFiles'
--
--	DECLARE @hr int,@fso int,@mbtotal int,@TotalSpace int,@MBFree int,@Percentage int,
--	@SQLDriveSize int,@size float, @drive Varchar(1),@fso_Method varchar(255)
--
--	SET @mbTotal = 0
--
--	EXEC @hr = master.dbo.sp_OACreate 'Scripting.FilesystemObject', @fso OUTPUT
--
--	CREATE TABLE #space (drive char(1), mbfree int)
--	INSERT INTO #space EXEC master.dbo.xp_fixeddrives
--	
--	Declare CheckDrives Cursor For SELECT drive,MBfree From #space
--	Open CheckDrives
--		Fetch Next from CheckDrives into @Drive, @MBFree
--		WHILE(@@FETCH_STATUS=0)
--		BEGIN
--			SET @fso_Method = 'Drives("' + @drive + ':").TotalSize'
--			SELECT	@SQLDriveSize=sum(Convert(Int,tamanho))
--			From	#dbspace where Substring(caminho,1,1)=@drive
--	
--			EXEC @hr = sp_OAMethod @fso, @fso_method, @size OUTPUT
--			SET @mbtotal =  @size / (1024 * 1024)
--			INSERT INTO #espacodisco
--			VALUES(@Drive+ ':',@MBTotal,@MBTotal-@MBFree,@MBFree,(100 * round(@MBFree,2) / round(@MBTotal,2)),
--			(100 - 100 * round(@MBFree,2) / round(@MBTotal,2)),@SQLDriveSize, getdate())
--
--			FETCH NEXT FROM CheckDrives INTO @drive,@mbFree
--		END
--	CLOSE CheckDrives
--	DEALLOCATE CheckDrives
--
--	IF (OBJECT_ID('EspacoEmDisco') IS NOT NULL)  
--		drop table EspacoEmDisco
--
--	SELECT Drive, [Tamanho (MB)],[Usado (MB)] , [Livre (MB)]/1024 , [Livre (%)],[Usado (%)] ,
--	ISNULL ([Ocupado SQL (MB)],0) AS [Ocupado SQL (MB)]
--	into dbo.EspacoEmDisco
--	FROM #espacodisco
--
--	DROP TABLE #dbspace
--	DROP TABLE #space
--	DROP TABLE #espacodisco
--
--END
--
------ Criando planilha excel
------ ABA ESPAÇO DISCO
----INSERT INTO OPENROWSET('Microsoft.Jet.OLEDB.4.0',
----'Excel 8.0;Database=C:\FabricioLima\CheckList\CheckList do Banco de Dados.xls;',
----'SELECT Drive,    [Tamanho(MB)],[Utilizado(MB)],[Livre(MB)],[Utilizado(%)],[Livre(%)],[Ocupado SQL(MB)]  FROM [Espaço Disco$]')
----SELECT Drive,[Tamanho (MB)],[Usado (MB)],[Livre (MB)],[Usado (%)],[Livre (%)],[Ocupado SQL (MB)]
----from _CheckList_Espacodisco
--
---- ******************************
---- Monitoramento dos arquivos SQL
---- ******************************
--
--CREATE PROCEDURE [dbo].[stpMonitora_ArquivosSQL]
--AS
--BEGIN
--	IF (OBJECT_ID('ArquivosSQL') IS NOT NULL)  
--		drop table ArquivosSQL
--
--		Create table dbo.ArquivosSQL (
--		[Name] varchar(250) , [FileName] varchar(250) , [Size] bigint, [MaxSize] bigint, Growth varchar(100), Proximo_Tamanho bigint, Situacao varchar(15))
--
--		Insert into dbo.ArquivosSQL
--		SELECT	convert(varchar, name) as NAME
--		,		Filename
--		,		cast(Size * 8 as bigint) / 1024.00 Size
--		,		Case when MaxSize = -1 then -1 
--				Else cast(MaxSize  as bigint)* 8 / 1024.00
--				End MaxSize
--		,		Case when substring(cast(Status as varchar),1,2) = 10 then cast(Growth as varchar) + ' %'
--				Else cast (cast((Growth * 8 )/1024.00 as numeric(15,2)) as varchar) + ' MB'
--				End Growth
--		,		Case when substring(cast(Status as varchar),1,2) = 10 then (cast(Size as bigint) * 8 / 1024.00) * ((Growth/100.00) + 1)
--				Else (cast(Size  as bigint) * 8 / 1024.00) + cast((Growth * 8 )/1024.00 as numeric(15,2))
--				End Proximo_Tamanho
--		,		Case when MaxSize = -1 then 'OK'  -- OK
--				When (	Case when substring(cast(Status as varchar),1,2) = 10
--						Then (cast(Size  as bigint)* 8 / 1024.00) * ((Growth/100.00) + 1)	
--						Else (cast(Size  as bigint) * 8/ 1024.00) + cast((Growth * 8 )/1024.00 as numeric(15,2))
--						End )  <  (cast(MaxSize  as bigint) * 8/1024.00)  then  'OK' else 'PROBLEMA'
--				End Situacao
--		From master..sysaltfiles with(nolock)
--		Order by Situacao, Size desc
--END
--
---- ****************************
---- Utilização do Arquivo de Log
---- ****************************
--CREATE procedure [dbo].[StpVerifica_Utilizacao_Log_Aux]
--As
--	DBCC SQLPERF (LOGSPACE)
--
--CREATE procedure [dbo].[StpVerifica_Utilizacao_Log]
--As
--BEGIN
--	IF (OBJECT_ID('UtilizacaoLog') IS NOT NULL)  DROP TABLE UtilizacaoLog
--
--    Create table dbo.UtilizacaoLog (
--		Nm_Database varchar(50)
--	,	Log_Size numeric(15,2)
--	,	[Log_Space_Used(%)] numeric(15,2)
--	,	status_log int)
--
--    insert dbo.UtilizacaoLog
--    exec dbo.StpVerifica_Utilizacao_Log_Aux
--END
--
---- ******
---- Backup
---- ******
--ALTER procedure [dbo].[StpVerifica_Backups]
--As
--BEGIN
--    IF (OBJECT_ID('Backups') IS NOT NULL)
--		DROP TABLE Backups
--
--    Create table Backups (database_name nvarchar(256),name nvarchar(256), backup_start_date datetime,tempo int
--    , server_name nvarchar(256), recovery_model nvarchar(120), tamanho  int)
--
--    DECLARE @Dt_Referencia datetime
--    SELECT @Dt_Referencia = cast(floor(cast(GETDATE() as float)) as datetime) -- Hora zerada
--
--    insert	dbo.Backups
--    SELECT	database_name
--	,		name
--	,		Backup_start_date
--	,		datediff(mi,Backup_start_date,Backup_finish_date) [tempo (min)]
--	,		server_name
--	,		recovery_model
--	--,		cast(backup_size/1024/1024 as numeric(15,2)) [Tamanho (MB)] 
--	,		(backup_size/1024) + 1 [Tamanho (KB)] 
--    FROM	msdb.dbo.backupset B
--    INNER JOIN msdb.dbo.backupmediafamily BF ON B.media_set_id = BF.media_set_id
--    Where	Backup_start_date >= dateadd(hh, 23 ,@Dt_Referencia - 2 ) -- backups realizados a partir das 23h de antes de ontem
--    and		Backup_start_date < dateadd (day, 1, @Dt_Referencia)
--   -- and type = 'D'
--	Order by
--			database_name
--	,		Backup_start_date
--END
--
---- ***************
---- Jobs executando
---- ***************
--CREATE procedure [dbo].[StpVerifica_JobsRodando]
--As
--BEGIN
--	IF (OBJECT_ID('JobsRodando') IS NOT NULL)  
--		DROP TABLE JobsRodando
--
--    Create table dbo.JobsRodando(
--		Name varchar(256)
--	,	Data_Inicio datetime
--	,	Tempo_Rodando int )
--    
--	Insert into dbo.JobsRodando
--    SELECT	name
--	,		run_Requested_Date
--	,		datediff(mi,run_Requested_Date,getdate())
--    From	msdb..sysjobactivity A
--    join	msdb..sysjobs B on A.job_id = B.job_id
--    Where	start_Execution_Date is not null 
--	and		stop_execution_date is null
--END
--
---------------------- ARRUMAR
--
---- *****************
---- Jobs que falharam
---- *****************
--	if OBJECT_ID('Tempdb..#Result_History_Jobs') is not null    drop table #Result_History_Jobs
--
--	create table #Result_History_Jobs(
--	Cod int identity(1,1),Instance_Id int, Job_Id varchar(255),Job_Name varchar(255),Step_Id int,Step_Name varchar(255),
--	Sql_Message_Id int,Sql_Severity int,SQl_Message varchar(3990),Run_Status int, Run_Date varchar(20),
--	Run_Time varchar(20),Run_Duration int,Operator_Emailed varchar(100),Operator_NetSent varchar(100),
--	Operator_Paged varchar(100),Retries_Attempted int, Nm_Server varchar(100))
--
--	IF (OBJECT_ID('JobsFailed') IS NOT NULL)  DROP TABLE JobsFailed
--
--	declare @hoje varchar (8)
--	declare @ontem varchar (8)
--	set @ontem  =  convert (varchar(8),(dateadd (day, -1, getdate())),112)
--
--	insert into #Result_History_Jobs
--	exec Msdb.dbo.SP_HELP_JOBHISTORY @mode = 'FULL' , @start_run_date =  @ontem
--
--	SELECT Job_Name, case when Run_Status = 0 then 'Failed'
--	when Run_Status = 1 then 'Succeeded'
--	when Run_Status = 2 then 'Retry (step only)'
--	when Run_Status = 3 then 'Canceled'
--	when Run_Status = 4 then 'In-progress message'
--	when Run_Status = 5 then 'Unknown' end Status,
--	cast(Run_Date + ' ' +
--	right('00' + substring(Run_time,(len(Run_time)-5),2) ,2)+ ':' +
--	right('00' + substring(Run_time,(len(Run_time)-3),2) ,2)+ ':' +
--	right('00' + substring(Run_time,(len(Run_time)-1),2) ,2) as varchar) Dt_Execucao,
--	right('00' + substring(cast(Run_Duration as varchar),(len(Run_Duration)-5),2) ,2)+ ':' +
--	right('00' + substring(cast(Run_Duration as varchar),(len(Run_Duration)-3),2) ,2)+ ':' +
--	right('00' + substring(cast(Run_Duration as varchar),(len(Run_Duration)-1),2) ,2)  Run_Duration,
--	SQL_Message
--	into dbo.JobsFailed
--	from #Result_History_Jobs
--	where
--	cast(Run_Date + ' ' + right('00' + substring(Run_time,(len(Run_time)-5),2) ,2)+ ':' +
--	right('00' + substring(Run_time,(len(Run_time)-3),2) ,2)+ ':' +
--	right('00' + substring(Run_time,(len(Run_time)-1),2) ,2) as datetime) >= @ontem + '17:00'   -- dia anterior no horário
--	and Step_Id = 0
--	and Run_Status <> 1
--	order by Dt_Execucao
--	
--	
---- ******************
---- Consumo de memória
---- ******************
--
---- Declarando a varíavel @Buffers_EmUso
--Declare @Buffers_EmUso Int;
--/* Acumando o valor dos contadores na variável @Buffers_EmUso, 
--filtrando pelo Object_Name=Buffer Manager e Counter_Name=Total Pages*/
--
--SELECT @Buffers_EmUso = cntr_value From Sys.dm_os_performance_counters
--Where Rtrim(Object_name) LIKE '%Buffer Manager'
--And counter_name = 'Total Pages';
--
---- Declarando a CTE Buffers_Pages para contagem de Buffers por página –
--;With DB_Buffers_Pages AS
--(	SELECT database_id, Contagem_Buffers_Por_Pagina  = COUNT_BIG(*)
--	From Sys.dm_os_buffer_descriptors
--	Group By database_id
--)
--
---- Retornando informações sobre os pools de Buffers por Banco de Dados com base 
---- na CTE DB_Buffers_Pages
--
--SELECT	Case [database_id] WHEN 32767 Then 'Recursos de Banco de Dados'
--			Else DB_NAME([database_id]) End As 'Banco de Dados'
--,		Contagem_Buffers_Por_Pagina
--,		'Buffers em MBs por Banco' = Contagem_Buffers_Por_Pagina / 128
--,		'Porcentagem de Buffers' = CONVERT(DECIMAL(6,3)
--,		Contagem_Buffers_Por_Pagina * 100.0 / @Buffers_EmUso)
--From	DB_Buffers_Pages
--Order By 'Buffers em MBs por Banco' Desc;
--
--
-------------
--POR TABELA
-------------
--USE TopManager
--GO
---- Declarando a CTE Buffers_Pages para retorno dos Objetos alocados em Pool –
--;WITH DB_Buffers_Pages_Objetos AS
--(
--	SELECT	SO.name As Objeto
--	,		SO.type_desc As TipoObjeto
--	,		COALESCE(SI.name, '') As Indice
--	,		SI.type_desc As TipoIndice
--	,		p.[object_id]
--	,		p.index_id
--	,		AU.allocation_unit_id
--	From	sys.partitions AS P 
--	INNER JOIN sys.allocation_units AS AU ON p.hobt_id = au.container_id
--	INNER JOIN sys.objects AS SO ON p.[object_id] = SO.[object_id]
--	INNER JOIN sys.indexes AS SI ON SO.[object_id] = SI.[object_id] 
--		AND p.index_id = SI.index_id
--	Where	AU.[type] IN (1,2,3)
--	And		SO.is_ms_shipped = 0
--)
--
---- Retornando informações sobre os pools de Buffers de Objetos por Banco de Dados 
---- com base na CTE DB_Buffers_Pages_Objetos –
--
--SELECT	Db.Objeto
--,		Db.TipoObjeto  As 'Tipo Objeto'
--,		Db.Indice
--,		Db.TipoIndice
--,		COUNT_BIG(b.page_id) As 'Buffers Por Página'
--,		COUNT_BIG(b.page_id) / 128 As 'Buffers em MBs'
--From	DB_Buffers_Pages_Objetos Db 
--INNER JOIN sys.dm_os_buffer_descriptors AS b ON Db.allocation_unit_id = b.allocation_unit_id
--Where	b.database_id = DB_ID()
--Group By	Db.Objeto
--,			Db.TipoObjeto
--,			Db.Indice
--,			Db.TipoIndice
--Order By	'Buffers Por Página' Desc
--,			TipoIndice Desc;
--	
--
---- *********************
---- Atualiza Estatísticas
---- *********************
---- Arrumar...
----CREATE PROCEDURE [dbo].[stpAtualiza_Estatisticas]
----As
----BEGIN
----	SET NOCOUNT ON
----	-- Sai da rotina quando a janela de manutenção é finalizada
----	IF GETDATE() > dateadd(mi,+50,dateadd(hh,+23,cast(floor(cast(getdate()as float))as datetime)))- hora > 23:50)
----	BEGIN
----		RETURN
----	END
--
----	Create table #Atualiza_Estatisticas(
----		Id_Estatistica int identity(1,1)
----	,	Ds_Comando varchar(4000)
----	,	Nr_Linha int)
--
----	;WITH Tamanho_Tabelas AS (
----	SELECT	obj.name
----	,		prt.rows
----	FROM	sys.objects obj
----	JOIN	sys.indexes idx on obj.object_id= idx.object_id
----	JOIN	sys.partitions prt on obj.object_id= prt.object_id
----	JOIN	sys.allocation_units alloc on alloc.container_id= prt.partition_id
----	WHERE	obj.type= 'U' AND idx.index_id IN (0, 1)and prt.rows > 1000
----	GROUP BY 
----			obj.name, prt.rows)
--
----	insert into #Atualiza_Estatisticas(Ds_Comando,Nr_Linha)
----	SELECT	'UPDATE STATISTICS ' + B.name+ ' ' + A.name+ ' WITH FULLSCAN'
----	,		D.rows
----	FROM	sys.stats A
----	join	sys.sysobjects B on A.object_id = B.id
----	join	sys.sysindexes C on C.id = B.id and A.name= C.Name
----	JOIN	Tamanho_Tabelas D on  B.name= D.Name
----	WHERE	C.rowmodctr > 100
----	and		C.rowmodctr> D.rows*.005
----	and		substring( B.name,1,3) not in ('sys','dtp')
----	ORDER BY 
----			D.rows
--
----	declare @Loop int, @Comando nvarchar(4000)
----	set @Loop = 1
--
----	while exists(SELECT top 1 null from #Atualiza_Estatisticas)
----	begin
--
----	IF GETDATE()> dateadd(mi,+50,dateadd(hh,+23,cast(floor(cast(getdate()as float))as datetime)))-hora > 23:50 am
----	BEGIN
----		BREAK -- Sai do loop quando acabar a janela de manutenção
----	END
--
----	SELECT	@Comando = Ds_Comando
----	from	#Atualiza_Estatisticas
----	where	Id_Estatistica = @Loop
--
----	--EXECUTE sp_executesql @Comando -- ESTA É A QUE EXECUTA
--
----	delete from #Atualiza_Estatisticas
----	where Id_Estatistica = @Loop
--
----	set @Loop= @Loop + 1
----	end
----END
--	
---------------------- SUGESTÕES:
----    Crescimento de tabelas
----    Crescimento das databases
----    Objetos que foram alterados
----    Procedimentos mais demorados
----    Fragmentação dos Índices