-- https://msdn.microsoft.com/pt-br/library/ms179984(v=sql.120).aspx

-- Os conteúdos desta exibição de gerenciamento dinâmico podem ser reajustados executando o seguinte comando:
-- DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR); -- Esse comando redefine todos os contadores como 0.
-- GO

SELECT wait_type           -- Nome do tipo de espera. Para obter mais informações, consulte Tipos de espera mais adiante neste tópico.
     , waiting_tasks_count -- Número de esperas nesse tipo de espera. O contador é incrementado no início de cada espera.
     , wait_time_ms        -- Tempo de espera total para esse tipo de espera em milissegundos. Esse tempo é inclusivo do signal_wait_time_ms.
     , max_wait_time_ms    -- Tempo de espera máximo neste tipo de espera.
     , signal_wait_time_ms -- Diferença entre a hora em que o thread de espera foi sinalizado e quando ele começou a ser executado.
     , 100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage]
     
     , Média = wait_time_ms / waiting_tasks_count
  FROM sys.dm_os_wait_stats
 WHERE [wait_type] NOT IN (
        N'BROKER_EVENTHANDLER',         N'BROKER_RECEIVE_WAITFOR',
        N'BROKER_TASK_STOP',            N'BROKER_TO_FLUSH',
        N'BROKER_TRANSMITTER',          N'CHECKPOINT_QUEUE',
        N'CHKPT',                       N'CLR_AUTO_EVENT',
        N'CLR_MANUAL_EVENT',            N'CLR_SEMAPHORE',
        N'DBMIRROR_DBM_EVENT',          N'DBMIRROR_EVENTS_QUEUE',
        N'DBMIRROR_WORKER_QUEUE',       N'DBMIRRORING_CMD',
        N'DIRTY_PAGE_POLL',             N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC',                    N'FSAGENT',
        N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
        N'HADR_CLUSAPI_CALL',           N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
        N'HADR_LOGCAPTURE_WAIT',        N'HADR_NOTIFICATION_DEQUEUE',
        N'HADR_TIMER_TASK',             N'HADR_WORK_QUEUE',
        N'KSOURCE_WAKEUP',              N'LAZYWRITER_SLEEP',
        N'LOGMGR_QUEUE',                N'ONDEMAND_TASK_QUEUE',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED',
        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
        N'REQUEST_FOR_DEADLOCK_SEARCH', N'RESOURCE_QUEUE',
        N'SERVER_IDLE_CHECK',           N'SLEEP_BPOOL_FLUSH',
        N'SLEEP_DBSTARTUP',             N'SLEEP_DCOMSTARTUP',
        N'SLEEP_MASTERDBREADY',         N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED',        N'SLEEP_MSDBSTARTUP',
        N'SLEEP_SYSTEMTASK',            N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP',         N'SNI_HTTP_ACCEPT',
        N'SP_SERVER_DIAGNOSTICS_SLEEP', N'SQLTRACE_BUFFER_FLUSH',
        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        N'SQLTRACE_WAIT_ENTRIES',       N'WAIT_FOR_RESULTS',
        N'WAITFOR',                     N'WAITFOR_TASKSHUTDOWN',
        N'WAIT_XTP_HOST_WAIT',          N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
        N'WAIT_XTP_CKPT_CLOSE',         N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT',          N'XE_TIMER_EVENT')
AND waiting_tasks_count > 0
ORDER BY wait_time_ms desc;

-- Maiores na GR

-- CXPACKET
-----------
-- Ocorre com planos de consulta paralelas ao tentar sincronizar o iterador de troca de processador de consulta. Se a espera for excessiva e não puder ser reduzida ajustando a consulta (como adicionando índices), ajuste o limite de custo para paralelismo ou reduza o grau de paralelismo.

-- LATCH_EX
-----------
-- https://msdn.microsoft.com/pt-br/library/ms175066.aspx
-- Ocorre ao esperar uma trava de EX (exclusivo). Isso não inclui travas de buffer ou de marcação de transação. Uma listagem de esperas de LATCH_* está disponível em sys.dm_os_latch_stats. Observe que sys.dm_os_latch_stats agrupa LATCH_NL, LATCH_SH, LATCH_UP, LATCH_EX e LATCH_DT.
-- DBCC SQLPERF ('sys.dm_os_latch_stats', CLEAR);
-- GO

-- SELECT * FROM sys.dm_os_latch_stats WHERE [waiting_requests_count] > 0 ORDER BY [wait_time_ms] DESC;
-- GO

-- - Maiores na GR
-- -- ACCESS_METHODS_DATASET_PARENT
-- -- BUFFER

-- SOS_SCHEDULER_YIELD
----------------------
-- Ocorre quando uma tarefa cede o agendador para a execução de outras tarefas. Durante essa espera, a tarefa espera que seu quantum seja renovado.

-- WRITELOG
-----------
-- Ocorre ao aguardar que uma liberação de log seja concluída. As operações comuns que causam liberações de log são pontos de verificação e confirmações de transação.





-- OUTRA FORMA
--------------
-- Retorna Wait Statistics
--WITH [Waits] AS
--    (SELECT
--        [wait_type],
--        [wait_time_ms] / 1000.0 AS [WaitS],
--        [signal_wait_time_ms] / 1000.0 AS [SignalS],
--        ([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
--        [waiting_tasks_count] AS [WaitCount],
--        100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
--        ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]
--    FROM sys.dm_os_wait_stats
--    WHERE [wait_type] NOT IN (
--        N'BROKER_EVENTHANDLER',         N'BROKER_RECEIVE_WAITFOR',
--        N'BROKER_TASK_STOP',            N'BROKER_TO_FLUSH',
--        N'BROKER_TRANSMITTER',          N'CHECKPOINT_QUEUE',
--        N'CHKPT',                       N'CLR_AUTO_EVENT',
--        N'CLR_MANUAL_EVENT',            N'CLR_SEMAPHORE',
--        N'DBMIRROR_DBM_EVENT',          N'DBMIRROR_EVENTS_QUEUE',
--        N'DBMIRROR_WORKER_QUEUE',       N'DBMIRRORING_CMD',
--        N'DIRTY_PAGE_POLL',             N'DISPATCHER_QUEUE_SEMAPHORE',
--        N'EXECSYNC',                    N'FSAGENT',
--        N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
--        N'HADR_CLUSAPI_CALL',           N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
--        N'HADR_LOGCAPTURE_WAIT',        N'HADR_NOTIFICATION_DEQUEUE',
--        N'HADR_TIMER_TASK',             N'HADR_WORK_QUEUE',
--        N'KSOURCE_WAKEUP',              N'LAZYWRITER_SLEEP',
--        N'LOGMGR_QUEUE',                N'ONDEMAND_TASK_QUEUE',
--        N'PWAIT_ALL_COMPONENTS_INITIALIZED',
--        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
--        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
--        N'REQUEST_FOR_DEADLOCK_SEARCH', N'RESOURCE_QUEUE',
--        N'SERVER_IDLE_CHECK',           N'SLEEP_BPOOL_FLUSH',
--        N'SLEEP_DBSTARTUP',             N'SLEEP_DCOMSTARTUP',
--        N'SLEEP_MASTERDBREADY',         N'SLEEP_MASTERMDREADY',
--        N'SLEEP_MASTERUPGRADED',        N'SLEEP_MSDBSTARTUP',
--        N'SLEEP_SYSTEMTASK',            N'SLEEP_TASK',
--        N'SLEEP_TEMPDBSTARTUP',         N'SNI_HTTP_ACCEPT',
--        N'SP_SERVER_DIAGNOSTICS_SLEEP', N'SQLTRACE_BUFFER_FLUSH',
--        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
--        N'SQLTRACE_WAIT_ENTRIES',       N'WAIT_FOR_RESULTS',
--        N'WAITFOR',                     N'WAITFOR_TASKSHUTDOWN',
--        N'WAIT_XTP_HOST_WAIT',          N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
--        N'WAIT_XTP_CKPT_CLOSE',         N'XE_DISPATCHER_JOIN',
--        N'XE_DISPATCHER_WAIT',          N'XE_TIMER_EVENT')
--    )

--SELECT
--    [W1].[wait_type] AS [WaitType],
--    CAST ([W1].[WaitS] AS DECIMAL (16, 2)) AS [Wait_S],
--    CAST ([W1].[SignalS] AS DECIMAL (16, 2)) AS [Signal_S],
--    CAST ([W1].[ResourceS] AS DECIMAL (16, 2)) AS [Resource_S],
--    [W1].[WaitCount] AS [WaitCount],
--    CAST ([W1].[Percentage] AS DECIMAL (5, 2)) AS [Percentage],
--    CAST (([W1].[WaitS] / [W1].[WaitCount]) AS DECIMAL (16, 4)) AS [AvgWait_S],
--    CAST (([W1].[ResourceS] / [W1].[WaitCount]) AS DECIMAL (16, 4)) AS [AvgRes_S],
--    CAST (([W1].[SignalS] / [W1].[WaitCount]) AS DECIMAL (16, 4)) AS [AvgSig_S]
--FROM [Waits] AS [W1]
--INNER JOIN [Waits] AS [W2]
--    ON [W2].[RowNum] <= [W1].[RowNum]
--GROUP BY [W1].[RowNum], [W1].[wait_type], [W1].[WaitS],
--    [W1].[ResourceS], [W1].[SignalS], [W1].[WaitCount], [W1].[Percentage]
--HAVING SUM ([W2].[Percentage]) - [W1].[Percentage] < 95; -- percentage threshold
--GO