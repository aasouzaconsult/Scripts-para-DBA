--Criar Monitoração
CREATE EVENT SESSION [XE_TRAN_MONITOR] ON SERVER 
ADD EVENT sqlserver.database_transaction_begin(
    ACTION(sqlserver.database_name,sqlserver.session_id,
	sqlserver.sql_text)
    WHERE ([sqlserver].[database_id]=(5))),
ADD EVENT sqlserver.database_transaction_end(
    ACTION(sqlserver.database_name,sqlserver.session_id,
	sqlserver.sql_text)
    WHERE ([sqlserver].[database_id]=(5))) 
ADD TARGET package0.pair_matching(
SET begin_event=N'sqlserver.database_transaction_begin',
begin_matching_actions=N'sqlserver.session_id',end_event=N'sqlserver.database_transaction_end',end_matching_actions=N'sqlserver.session_id')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=1 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

--Simulando locks
BEGIN TRANSACTION
UPDATE PERSON.Person
SET FirstName = 'Ze'

--Visualizar dados do target
SELECT name, target_name, CAST(xet.target_data AS xml)
FROM sys.dm_xe_session_targets AS xet
JOIN sys.dm_xe_sessions AS xe
   ON (xe.address = xet.event_session_address)
WHERE xe.name = 'XE_BLOCK_MONITOR'