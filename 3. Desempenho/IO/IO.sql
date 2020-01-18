-----------------------------------------------------------------------------------------------------------------------------
SELECT wait_type            -- Nome do tipo de espera. 
     , waiting_tasks_count  -- Número de esperas nesse tipo de espera. O contador é incrementado no início de cada espera. 
     , wait_time_ms         -- Tempo de espera total para esse tipo de espera em milissegundos. Essa hora é inclusiva de signal_wait_time_ms.
     , max_wait_time_ms     -- Tempo de espera máximo neste tipo de espera.
     , signal_wait_time_ms  -- Diferença entre a hora em que o thread de espera foi sinalizado e quando ele começou a ser executado. 
  FROM sys.dm_os_wait_stats -- http://msdn.microsoft.com/pt-br/library/ms179984%28v=sql.105%29.aspx
 WHERE wait_type like 'PAGEIOLATCH%'
 ORDER BY wait_type
 
-- PAGEIOLATCH_DT
-- Ocorre quando uma tarefa está esperando em uma trava por um buffer que está em uma solicitação de E/S. 
-- A solicitação de trava está no modo Destruição. Esperas longas podem indicar problemas no subsistema de disco.

-- PAGEIOLATCH_EX
-- Ocorre quando uma tarefa está esperando em uma trava por um buffer que está em uma solicitação de E/S. 
-- A solicitação de trava está em modo Exclusivo. Esperas longas podem indicar problemas no subsistema de disco.

-- PAGEIOLATCH_KP
-- Ocorre quando uma tarefa está esperando em uma trava por um buffer que está em uma solicitação de E/S. 
-- A solicitação de trava está no modo Manutenção. Esperas longas podem indicar problemas no subsistema de disco.

-- PAGEIOLATCH_NL
-- Identificado apenas para fins informativos. Sem suporte. A compatibilidade futura não está garantida.

-- PAGEIOLATCH_SH
-- Ocorre quando uma tarefa está esperando em uma trava por um buffer que está em uma solicitação de E/S. 
-- A solicitação de trava está no modo Compartilhado. Esperas longas podem indicar problemas no subsistema de disco.

-- PAGEIOLATCH_UP
-- Ocorre quando uma tarefa está esperando em uma trava por um buffer que está em uma solicitação de E/S. 
-- A solicitação de trava está no modo Atualização. Esperas longas podem indicar problemas no subsistema de disco.

-----------------------------------------------------------------------------------------------------------------------------
-- Following query shows the number of pending I/Os that are waiting to be completed for the entire SQL Server instance:
SELECT SUM(pending_disk_io_count) AS [Number of pending I/Os] FROM sys.dm_os_schedulers 

-----------------------------------------------------------------------------------------------------------------------------
-- By looking at pending I/O requests and isolating the disks,File and database in which we have I/O Bottleneck.
SELECT t1.database_id
     , t3.name
     , t1.file_id
     , t1.io_stall
     , t2.io_pending_ms_ticks
     , t2.scheduler_address
     , t2.io_type
     , 'Auxiliares T1'
     , t1.*
     , 'Auxiliares T2'
     , t2.*
     , 'Auxiliares T3'
     , t3.*
  FROM sys.dm_io_virtual_file_stats(NULL, NULL) t1
  JOIN sys.dm_io_pending_io_requests            t2 ON t2.io_handle   = t1.file_handle
  JOIN sys.databases                            t3 ON t3.database_id = t1.database_id

-----------------------------------------------------------------------------------------------------------------------------
--SELECT T1.database_id,
--    DB_NAME(T1.database_id) as DbName,
--    T4.text,
--    T1.database_transaction_begin_time,
--    T1.database_transaction_state,
--    T1.database_transaction_log_bytes_used_system,
--    T1.database_transaction_log_bytes_reserved,
--    T1.database_transaction_log_bytes_reserved_system,
--    T1.database_transaction_log_record_count
--from sys.dm_tran_database_transactions T1
--join sys.dm_tran_session_transactions T2 on T2.transaction_id = T1.transaction_id
--join sys.dm_exec_requests T3 on T3.session_id = T2.session_id
--cross apply sys.dm_exec_sql_text(T3.sql_handle) T4
----where T1.database_transaction_state = 4 -- 4 : The transaction has generated log records.
----and T1.database_id = db_id()
--order by T1.database_transaction_log_record_count desc
----order by T1.database_transaction_log_bytes_reserved desc