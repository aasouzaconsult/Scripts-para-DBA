-- 1 Top 10 SQL statements with high Execution count
-- 1 Top 10 instruções SQL com contagem de Execução de alta

print '1. Top 10 SQL statements with high Execution count'
select top 10
    qs.execution_count,
    st.dbid,
    DB_NAME(st.dbid) as DbName,
    st.text
from sys.dm_exec_query_stats as qs
cross apply sys.dm_exec_sql_text(sql_handle) st
order by execution_count desc
go


-- 2 Top 10 SQL statements with high Duration
print '2. Top 10 SQL statements with high Duration'
select top 10
    qs.total_elapsed_time,
    st.dbid,
    DB_NAME(st.dbid) as DbName,
    st.text
from sys.dm_exec_query_stats as qs
cross apply sys.dm_exec_sql_text(sql_handle) st
order by total_elapsed_time desc
go


-- 3 Top 10 SQL statements with high CPU consumption
print '3. Top 10 SQL statements with high CPU consumption'
select top 10
    qs.sql_handle,
    qs.total_worker_time,
    st.dbid,
    DB_NAME(st.dbid) as DbName,
    st.text
from sys.dm_exec_query_stats as qs
cross apply sys.dm_exec_sql_text(sql_handle) st
order by total_worker_time desc
go
 
-- 4 Top 10 SQL statements with high Reads consumption
print '4. Top 10 SQL statements with high Reads consumption'
select top 10
    qs.total_logical_reads,
    st.dbid,
    DB_NAME(st.dbid) as DbName,
    st.text
from sys.dm_exec_query_stats as qs
cross apply sys.dm_exec_sql_text(sql_handle) st
order by total_logical_reads desc
go

-- 5 Top 10 SQL statements with high Writes consumption
print '5. Top 10 SQL statements with high Writes consumption'
select top 10
    qs.total_logical_writes,
    st.dbid,
    DB_NAME(st.dbid) as DbName,
    st.text
from sys.dm_exec_query_stats as qs
cross apply sys.dm_exec_sql_text(sql_handle) st
order by total_logical_writes desc
go


-- 6 Top 10 SQL statements with excessive compiles/recompiles.
print '6. Top 10 SQL statements with excessive compiles/recompiles'
select top 10
    qs.plan_generation_num, -- plan_generation_num column indicates the number of times the statements has recompiled.
    st.dbid,
    DB_NAME(st.dbid) as DbName,
    st.text
from sys.dm_exec_query_stats qs
cross apply sys.dm_exec_sql_text(sql_handle) as st
order by plan_generation_num desc
go

-- 7 locate queries that consume a large amount of log space
print '7. Queries that consume a large amount of log space'
select TOP(10)
    T1.database_id,
    DB_NAME(T1.database_id) as DbName,
    T4.text,
    T1.database_transaction_begin_time,
    T1.database_transaction_state,
    T1.database_transaction_log_bytes_used_system,
    T1.database_transaction_log_bytes_reserved,
    T1.database_transaction_log_bytes_reserved_system,
    T1.database_transaction_log_record_count
from sys.dm_tran_database_transactions T1
join sys.dm_tran_session_transactions T2 on T2.transaction_id = T1.transaction_id
join sys.dm_exec_requests T3 on T3.session_id = T2.session_id
cross apply sys.dm_exec_sql_text(T3.sql_handle) T4
--where T1.database_transaction_state = 4 -- 4 : The transaction has generated log records.
--and T1.database_id = db_id()
order by T1.database_transaction_log_record_count desc
--order by T1.database_transaction_log_bytes_reserved desc
go