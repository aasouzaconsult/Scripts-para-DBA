-- Usuários conectados
-------------------------------------------------------------------
SELECT login_name
, COUNT(*) as Qtd
FROM 
    sys.dm_exec_sessions 
WHERE
    login_name NOT IN ('sa', 'AUTORIDADE NT\SISTEMA', 'NT AUTHORITY\SYSTEM')
GROUP BY login_name

-- Detalhes
--SELECT 
--    session_id,
--    login_time,
--    host_name,
--    program_name,
--    client_interface_name,
--    login_name,
--    status,
--    cpu_time,
--    memory_usage,
--    last_request_start_time,
--    last_request_end_time,
--    transaction_isolation_level,
--    lock_timeout,
--    deadlock_priority
--FROM 
--    sys.dm_exec_sessions 
--WHERE
--    login_name NOT IN ('sa', 'AUTORIDADE NT\SISTEMA', 'NT AUTHORITY\SYSTEM')


-- Como identificar sessões inativas com transações abertas no SQL Server
-------------------------------------------------------------------
SELECT 
    A.session_id,
    A.login_time,
    A.host_name,
    A.program_name,
    A.login_name,
    A.status,
    A.cpu_time,
    A.memory_usage,
    A.last_request_start_time,
    A.last_request_end_time,
    A.transaction_isolation_level,
    A.lock_timeout,
    A.deadlock_priority,
    A.row_count,
    C.text
FROM 
    sys.dm_exec_sessions			A	WITH(NOLOCK)
    JOIN sys.dm_exec_connections		B	WITH(NOLOCK)	ON	A.session_id = B.session_id
    CROSS APPLY sys.dm_exec_sql_text(most_recent_sql_handle)	C
WHERE 
    EXISTS (SELECT * FROM sys.dm_tran_session_transactions AS t WITH(NOLOCK) WHERE t.session_id = A.session_id)
    AND NOT EXISTS (SELECT * FROM sys.dm_exec_requests AS r WITH(NOLOCK) WHERE r.session_id = A.session_id)
    
-- Como identificar as transações abertas na instância
-------------------------------------------------------------------
SELECT
    A.session_id,
    A.transaction_id,
    C.name AS database_name,
    B.database_transaction_begin_time,
    (CASE B.database_transaction_type
        WHEN 1 THEN 'Read/write transaction'
        WHEN 2 THEN 'Read-only transaction'
        WHEN 3 THEN 'System transaction'
    END) AS database_transaction_type,
    (CASE B.database_transaction_state
        WHEN 1 THEN 'The transaction has not been initialized.'
        WHEN 3 THEN 'The transaction has been initialized but has not generated any log records.'
        WHEN 4 THEN 'The transaction has generated log records.'
        WHEN 5 THEN 'The transaction has been prepared.'
        WHEN 10 THEN 'The transaction has been committed.'
        WHEN 11 THEN 'The transaction has been rolled back.'
        WHEN 12 THEN 'The transaction is being committed. In this state the log record is being generated, but it has not been materialized or persisted.'
    END) AS database_transaction_state,
    B.database_transaction_log_record_count
FROM
    sys.dm_tran_session_transactions A
    JOIN sys.dm_tran_database_transactions B ON A.transaction_id = B.transaction_id
    JOIN sys.databases C ON B.database_id = C.database_id
    
    
-- Eliminando as conexões de um database via KILL
-------------------------------------------------------------------
--DECLARE @query VARCHAR(MAX) = ''
 
--SELECT
--    @query = COALESCE(@query, ',') + 'KILL ' + CONVERT(VARCHAR, spid) + '; '
--FROM
--    master..sysprocesses
--WHERE
--    dbid = DB_ID('Testes') -- Nome do database
--    AND dbid > 4 -- Não eliminar sessões em databases de sistema
--    AND spid <> @@SPID -- Não eliminar a sua própria sessão
 
 
--IF (LEN(@query) > 0)
--    EXEC(@query)