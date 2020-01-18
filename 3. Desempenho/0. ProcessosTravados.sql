--------------------------------------------------------------
--EXEC AnaliseInstancia.[dbo].[stpVerifica_ProcessosTravados]
--SELECT [Tempo(ms)] = WaitMsQTy
--     , [Data/Hora] = getdate()
--     , Processo = CallingSpId
--     , [SQL do Processo] = CallingSQL
--     , CallingResourceType
--     , CallingRequestMode
--     , [Bloqueado por] = BlockingSpId
--     , [SQL Bloqueado por] = BlockingSQL
--     , BlockingResourceType
--     , BlockingRequestMode
--  FROM AnaliseInstancia..vw_dba_locks;
--------------------------------------------------------------
  
Declare @dbid int 
Select @dbid = dbid from master.dbo.sysdatabases --where name = 'TopManager'

Declare @Blocked Table (spid int) 
insert into @Blocked (spid) 
select distinct blocked from master.dbo.sysprocesses (nolock) where dbid = @dbid and blocked <> 0

/**********************
 * Processos travados *
 **********************/
Select		Tipo = 'TRAVADOS'
,			processes.spid
,			processes.blocked
,			processes.waittype
,			processes.waittime
,			processes.cpu
,			processes.physical_io 
,			processes.memusage 
,			processes.open_tran
,			processes.status 
,			st.text
,			processes.hostname
,			processes.loginame
from		master.dbo.sysprocesses processes (nolock) 
join		@Blocked Blo on Blo.spid = processes.spid 
cross apply sys.dm_exec_sql_text(processes.sql_handle) as st 
Where		Blocked = 0


/************************
 * Processos BLOQUEADOS *
 ************************/
Select 		Tipo = 'BLOQUEADOS'
,			processes.spid
,			processes.hostname
,			st.text as 'Comando'
,			processes.waittime
,			processes.cpu
,			processes.physical_io
,			ses.reads
,			ses.writes
,			processes.loginame
,			processes.status
From		master.dbo.sysprocesses processes (nolock) -- Processos
cross apply sys.dm_exec_sql_text(processes.sql_handle) as st -- Texto - SQL
join		sys.dm_exec_sessions ses (nolock) on ses.session_id = processes.spid --Sessões ativas
join		sys.dm_exec_connections con (nolock) on con.session_id = processes.spid

Where	processes.status <> 'sleeping'--148
and		processes.blocked > 0

Order by
	processes.cpu desc
,	processes.physical_io desc


/**********************
 * Todos os processos *
 **********************/
Select 		processes.spid
,			processes.hostname
,			processes.blocked
,			processes.waittype
,			processes.waittime
,			processes.cpu
,			processes.physical_io
,			ses.reads
,			ses.writes
,			Substring(processes.program_name, 1, 20) as 'Software'
,			processes.loginame
,			processes.status
,			st.text as 'Comando'
,			ses.client_interface_name as 'Tipo de Conexão'
,			ses.logical_reads
,			ses.host_process_id
,			processes.memusage
,			processes.open_tran
,			ses.client_version
,			ses.language
,			ses.date_format
,			ses.lock_timeout
,			ses.deadlock_priority
,			ses.row_count
,			Convert(varchar, con.client_net_address) + ' : ' + Convert(varchar, con.client_tcp_port) as 'IP Cliente'
,			con.auth_scheme as 'Autenticação'
,			Diversas = '>> *** DIVERSAS *** >>'
,			ses.*
,			con.*
From		master.dbo.sysprocesses processes (nolock) -- Processos
cross apply sys.dm_exec_sql_text(processes.sql_handle) as st -- Texto - SQL
join		sys.dm_exec_sessions ses (nolock) on ses.session_id = processes.spid --Sessões ativas
join		sys.dm_exec_connections con (nolock) on con.session_id = processes.spid

Where processes.status <> 'sleeping'--148

Order by
	processes.cpu desc
,	processes.physical_io desc

-- Links
-- http://blogs.msdn.com/sqlprogrammability/archive/2007/01/20/trouble-shooting-query-performance-issues-related-to-plan-cache-in-sql-2005-rtm-and-sp1.aspx