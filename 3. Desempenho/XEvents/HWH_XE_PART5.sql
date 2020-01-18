--Views de Catalago
SELECT * FROM sys.server_event_sessions
SELECT * FROM sys.server_event_session_events
WHERE event_session_id = 65544

SELECT * FROM sys.server_event_session_actions
WHERE event_session_id = 65544

SELECT * FROM sys.server_event_session_targets
WHERE event_session_id = 65544

--DMVs
SELECT * FROM 
sys.dm_xe_sessions AS se
INNER JOIN 
sys.dm_xe_session_events ev
ON se.address = ev.event_session_address
WHERE name = 'XE_DEADLOCK_MONITOR'

SELECT * FROM sys.dm_xe_session_targets

SELECT * FROM sys.dm_xe_session_event_actions