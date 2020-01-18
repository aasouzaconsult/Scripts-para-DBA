--http://blogs.msdn.com/b/sqlqueryprocessing/archive/2010/02/16/understanding-sql-server-memory-grant.aspx

--Find all queries waiting in the memory queue:
--Encontre todas as consultas em espera na fila de memória:
SELECT * FROM sys.dm_exec_query_memory_grants where grant_time is null

--Find who uses the most query memory grant:
--Descubra quem usa mais concessão de memória de consulta:
SELECT mg.granted_memory_kb, mg.session_id, t.text, qp.query_plan 
FROM sys.dm_exec_query_memory_grants AS mg
CROSS APPLY sys.dm_exec_sql_text(mg.sql_handle) AS t
CROSS APPLY sys.dm_exec_query_plan(mg.plan_handle) AS qp
ORDER BY 1 DESC OPTION (MAXDOP 1)

-- Search cache for queries with memory grants:
-- Pesquisa cache para consultas com concessões de memória:
SELECT t.text, cp.objtype,qp.query_plan
FROM sys.dm_exec_cached_plans AS cp
JOIN sys.dm_exec_query_stats AS qs ON cp.plan_handle = qs.plan_handle
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS t
WHERE qp.query_plan.exist('declare namespace n="http://schemas.microsoft.com/sqlserver/2004/07/showplan"; //n:MemoryFractions') = 1

-----------------------------------
-- Planos de Execução em Memória --
-----------------------------------
--http://leka.com.br/2011/11/02/quais-planos-de-execuo-esto-na-memria/
SELECT TOP 6
LEFT([name], 20) as [NOME],
LEFT([TYPE], 20) as [TIPO],
[single_pages_kb] + [multi_pages_kb] as [cache_kb],
[entries_count]
FROM sys.dm_os_memory_cache_counters
ORDER BY single_pages_kb + multi_pages_kb DESC

-------------------------------------------
-- Uso de memória por Banco da Instância --
-------------------------------------------
DECLARE @total_buffer INT;

SELECT @total_buffer = cntr_value
   FROM sys.dm_os_performance_counters
   WHERE RTRIM([object_name]) LIKE '%Buffer Manager'
   AND counter_name = 'Total Pages';

;WITH src AS
(
   SELECT
       database_id, db_buffer_pages = COUNT_BIG(*)
       FROM sys.dm_os_buffer_descriptors
       --WHERE database_id BETWEEN 5 AND 32766
       GROUP BY database_id
)
SELECT
   [db_name] = CASE [database_id] WHEN 32767
       THEN 'Resource DB'
       ELSE DB_NAME([database_id]) END,
   db_buffer_pages,
   db_buffer_MB = db_buffer_pages / 128,
   db_buffer_percent = CONVERT(DECIMAL(6,3),
       db_buffer_pages * 100.0 / @total_buffer)
FROM src
ORDER BY db_buffer_MB DESC;

----------------------------------
-- RING_BUFFER_RESOURCE_MONITOR --
----------------------------------
--http://www.codeproject.com/KB/database/Dynamic_Management_Views.aspx

--Este DMV usa RING_BUFFER_RESOURCE_MONITOR e dá informações de notificações monitor de recursos para identificar mudanças 
--de estado da memória. Internamente, o SQL Server tem um quadro que monitora as pressões de memória diferente. Quando as 
--mudanças de estado da memória, a tarefa de monitor de recursos gera uma notificação. Esta notificação é usado internamente 
--pelos componentes para ajustar seu uso de memória de acordo com o estado da memória.
--SELECT	CAST (record as xml) as Record
--FROM	sys.dm_os_ring_buffers 
--WHERE	ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR'

-- Condições de Falta de Memória
--SELECT	CAST (record as xml) as Record
--FROM	sys.dm_os_ring_buffers 
--WHERE	ring_buffer_type = 'RING_BUFFER_OOM'

SELECT	CONVERT (varchar(30), GETDATE(), 121) as runtime,
		DATEADD (ms, -1 * (sys.ms_ticks - a.[Record Time]), GETDATE()) AS Notification_time,
		a.* ,
		sys.ms_ticks AS [Current Time]
FROM  (SELECT	x.value('(//Record/ResourceMonitor/Notification)[1]', 'varchar(30)') AS [Notification_type], 
				x.value('(//Record/MemoryRecord/MemoryUtilization)[1]', 'bigint') AS [MemoryUtilization %], 
				x.value('(//Record/MemoryRecord/TotalPhysicalMemory)[1]', 'bigint') / 1024 AS [TotalPhysicalMemory_MB], 
				x.value('(//Record/MemoryRecord/AvailablePhysicalMemory)[1]', 'bigint') / 1024 AS [AvailablePhysicalMemory_MB], 
				x.value('(//Record/MemoryRecord/TotalPageFile)[1]', 'bigint') / 1024 AS [TotalPageFile_MB], 
				x.value('(//Record/MemoryRecord/AvailablePageFile)[1]', 'bigint') / 1024 AS [AvailablePageFile_MB], 
				x.value('(//Record/MemoryRecord/TotalVirtualAddressSpace)[1]', 'bigint') / 1024 AS [TotalVirtualAddressSpace_MB], 
				x.value('(//Record/MemoryRecord/AvailableVirtualAddressSpace)[1]', 'bigint') / 1024 AS [AvailableVirtualAddressSpace_MB], 
				x.value('(//Record/MemoryNode/@id)[1]', 'bigint') AS [Node Id], 
				x.value('(//Record/MemoryNode/ReservedMemory)[1]', 'bigint') / 1024 AS [SQL_ReservedMemory_MB], 
				x.value('(//Record/MemoryNode/CommittedMemory)[1]', 'bigint') / 1024 AS [SQL_CommittedMemory_MB], 
				x.value('(//Record/@id)[1]', 'bigint') AS [Record Id], 
				x.value('(//Record/@type)[1]', 'varchar(30)') AS [Type], 
				x.value('(//Record/ResourceMonitor/Indicators)[1]', 'bigint') AS [Indicators], 
				x.value('(//Record/@time)[1]', 'bigint') AS [Record Time]
		FROM (SELECT CAST (record as xml)
			  FROM sys.dm_os_ring_buffers 
			  WHERE ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR') AS R(x)) a 
CROSS JOIN sys.dm_os_sys_info sys
ORDER BY a.[Record Time] ASC


------------------------------------------------------
-- Listagem 1: Consultando o pool de buffers em uso --
------------------------------------------------------

-- Declarando a varíavel @Buffers_EmUso
Declare @Buffers_EmUso Int;
/* Acumando o valor dos contadores na variável @Buffers_EmUso, 
filtrando pelo Object_Name=Buffer Manager e Counter_Name=Total Pages*/

Select @Buffers_EmUso = cntr_value From Sys.dm_os_performance_counters
Where Rtrim(Object_name) LIKE '%Buffer Manager'
And counter_name = 'Total Pages';

-- Declarando a CTE Buffers_Pages para contagem de Buffers por página –
;With DB_Buffers_Pages AS
(	SELECT database_id, Contagem_Buffers_Por_Pagina  = COUNT_BIG(*)
	From Sys.dm_os_buffer_descriptors
	Group By database_id
)

-- Retornando informações sobre os pools de Buffers por Banco de Dados com base 
-- na CTE DB_Buffers_Pages

Select	Case [database_id] WHEN 32767 Then 'Recursos de Banco de Dados'
			Else DB_NAME([database_id]) End As 'Banco de Dados'
,		Contagem_Buffers_Por_Pagina
,		'Buffers em MBs por Banco' = Contagem_Buffers_Por_Pagina / 128
,		'Porcentagem de Buffers' = CONVERT(DECIMAL(6,3)
,		Contagem_Buffers_Por_Pagina * 100.0 / @Buffers_EmUso)
From	DB_Buffers_Pages
Order By 'Buffers em MBs por Banco' Desc;

---------------
--POR TABELA --
---------------
USE TopManager
GO
-- Declarando a CTE Buffers_Pages para retorno dos Objetos alocados em Pool –
;WITH DB_Buffers_Pages_Objetos AS
(
	Select	SO.name As Objeto
	,		SO.type_desc As TipoObjeto
	,		COALESCE(SI.name, '') As Indice
	,		SI.type_desc As TipoIndice
	,		p.[object_id]
	,		p.index_id
	,		AU.allocation_unit_id
	From	sys.partitions AS P 
	INNER JOIN sys.allocation_units AS AU ON p.hobt_id = au.container_id
	INNER JOIN sys.objects AS SO ON p.[object_id] = SO.[object_id]
	INNER JOIN sys.indexes AS SI ON SO.[object_id] = SI.[object_id] 
		AND p.index_id = SI.index_id
	Where	AU.[type] IN (1,2,3)
	And		SO.is_ms_shipped = 0
)

-- Retornando informações sobre os pools de Buffers de Objetos por Banco de Dados 
-- com base na CTE DB_Buffers_Pages_Objetos –
Select	Db.Objeto
,		Db.TipoObjeto  As 'Tipo Objeto'
,		Db.Indice
,		Db.TipoIndice
,		COUNT_BIG(b.page_id) As 'Buffers Por Página'
,		COUNT_BIG(b.page_id) / 128 As 'Buffers em MBs'
From	DB_Buffers_Pages_Objetos Db 
INNER JOIN sys.dm_os_buffer_descriptors AS b ON Db.allocation_unit_id = b.allocation_unit_id
Where	b.database_id = DB_ID()
Group By	Db.Objeto
,			Db.TipoObjeto
,			Db.Indice
,			Db.TipoIndice
Order By	'Buffers Por Página' Desc
,			TipoIndice Desc;
-- link: http://pedrogalvaojunior.wordpress.com/2011/06/09/determinando-o-uso-de-memoria-por-banco-de-dados-e-objetos-no-sql-server-2008/?utm_source=feedburner&utm_medium=email&utm_campaign=Feed%3A+SqlVirtualPassBrasil+%28SQL+Virtual+PASS+Brasil%29