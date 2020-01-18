-- Leituras lógicas - Consultas no Plano em Cache
SELECT TOP 1 WITH TIES
        total_logical_reads,
        last_logical_reads,
        min_logical_reads,
        max_logical_writes,
        sql_handle,
        plan_handle,
        query_hash,
        query_plan_hash,
        plan_generation_num,
        creation_time,
        last_execution_time,
        execution_count,
        total_physical_reads,
        total_logical_writes,
        total_elapsed_time,
        C.dbid,
        C.objectid,
        text,
        C.encrypted,
        query_plan
FROM sys.dm_exec_query_stats as EQS
CROSS APPLY sys.dm_exec_sql_text(EQS.sql_handle) AS C
CROSS APPLY sys.dm_exec_query_plan(EQS.plan_handle) AS T
ORDER BY total_logical_reads DESC
GO

-- Expectativa de Vida da Página no Cache (Média: 300 - Menor que isso expectativa baixa)
SELECT cntr_value AS [Page Life Expectancy]
FROM sys.dm_os_performance_counters
WHERE object_name LIKE '%Manager%'
AND counter_name = 'Page Life Expectancy'


-- Verificando o Wait Stats 
-- http://msdn.microsoft.com/pt-br/library/ms179984%28v=sql.105%29.aspx
-- CXPACKET - Ocorre ao tentar sincronizar o iterador de troca do processador de consulta. A redução do grau de paralelismo 
-- poderá ser considerada se a contenção nesse tipo de espera se tornar um problema.

WITH Waits AS
(
     SELECT wait_type,
             wait_time_ms / 1000. AS wait_time_sec,
           100. * wait_time_ms / SUM(wait_time_ms) OVER ( ) AS pct,
             ROW_NUMBER() OVER ( ORDER BY wait_time_ms DESC ) AS rn
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN ( 'CLR_SEMAPHORE', 'RESOURCE_QUEUE', 'SLEEP_TASK', 'SLEEP_SYSTEMTASK', 'XE_DISPATCHER_WAIT',
                         'WAITFOR', 'LOGMGR_QUEUE', 'FT_IFTS_SCHEDULER_IDLE_WAIT','FT_IFTS_SCHEDULER_IDLE_WAIT',
                         'BROKER_EVENTHANDLER', 'XE_TIMER_EVENT', 'REQUEST_FOR_DEADLOCK_SEARCH')
)

SELECT TOP 100 wait_type AS [Wait Type],
                CAST(wait_time_sec AS DECIMAL(12, 2)) AS [Wait Time (s)] ,
                  CAST(pct AS DECIMAL(12, 2)) AS [Wait Time (%)]
FROM Waits
ORDER BY wait_time_sec DESC

-- 4 – Verificando Leituras no Disco
SELECT DB_NAME(database_id) AS DatabaseName,
        FILE_ID,
        FILE_NAME(FILE_ID) AS NAME,
        D.io_stall_read_ms AS ReadsIOStall,
        D.num_of_reads AS NumsReads,
        CAST(D.io_stall_read_ms / (1.0 + num_of_reads) AS NUMERIC(10,1)) AS AvgReadsStall,
        io_stall_read_ms + io_stall_write_ms AS IOStalls,
        num_of_reads + num_of_writes AS TotalIO,
        CAST(( io_stall_read_ms + io_stall_write_ms ) / (1.0 + num_of_reads + num_of_writes) AS NUMERIC(10,1)) AS AvgIOStall
FROM sys.dm_io_virtual_file_stats(DB_ID(),NULL) AS D
