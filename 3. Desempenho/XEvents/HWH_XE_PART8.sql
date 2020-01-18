--https://tcalencar.wordpress.com/
--Criação da sessão de monitoração
CREATE EVENT SESSION [XE_BATCH_REQUESTS_DB] ON SERVER 
ADD EVENT sqlserver.sql_batch_completed(SET collect_batch_text=(1)
    ACTION(sqlserver.database_name)
    WHERE ([sqlserver].[database_name]=N'AdventureWorks2012')) 
ADD TARGET package0.event_counter
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

--Leitura do XML
SELECT 
Name,
CAST(target_data AS XML) AS XMLData,
CAST(target_data AS XML).value('(CounterTarget/Packages/Package/Event/@count)[1]', 'int')
AS CountExec
FROM sys.dm_xe_sessions AS s 
JOIN sys.dm_xe_session_targets AS t 
    ON t.event_session_address = s.address
