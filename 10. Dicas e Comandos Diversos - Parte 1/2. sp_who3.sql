Select 
		proces.spid
,		proces.ecid
,		proces.blocked
,		proces.status
,		bases.name as 'Banco'
,		proces.hostname as 'Host'
,		proces.loginame as 'Login'
,		proces.program_name as 'Aplicação'
,		proces.hostprocess
,		proces.cmd as 'Comando'
,		st.[text] as 'Query rodando' -- (*)
,		proces.lastwaittype
,		proces.nt_domain as 'Dominio'
,		proces.nt_username as 'Usuário'
,		proces.request_id
,		proces.cpu as 'Tempo CPU'
,		proces.waittime as 'Tempo Espera'
,		proces.physical_io 'Disco Entrada/Saida'
,		proces.login_time as 'Hora do Login'
,		proces.last_batch
,		proces.net_address
,		proces.net_library as 'Protocolo'
,		proces.open_tran as 'Transações em Aberto'
From		sys.sysprocesses proces
left join	sys.databases bases	on bases.database_id = proces. dbid
cross apply sys.dm_exec_sql_text(proces.sql_handle) as st -- Ver o que esta rodando (*)

--Where	bases.name = 'TopManager'
--and		proces.hostname = 'ti01'
--and		proces.spid = 352
Order by
		proces.cpu desc

-- ##########################
-- # Transações por segundo #
-- ##########################
--Select 
--		object_name as Servidor
--,		instance_name as Banco
--,		cntr_value as [Transações por Segundo]
--From	sysperfinfo
--Where	
--		counter_name = 'Transactions/sec' 

-- ###################################################
-- # Retorna as 5 Querys com maior tempo de execução #
-- ###################################################
--Select  Top 5
--		creation_time
--,		last_execution_time
--,		total_clr_time
--,		total_clr_time / execution_count as [Avg CLR Time]
--,		last_clr_time
--,		execution_count
--,		Substring (st.text, (qs.statement_start_offset / 2) + 1,
--		((Case statement_end_offset
--			when -1 then datalength(st.text)
--			else qs.statement_end_offset 
--			end -qs.statement_start_offset)/2) + 1) as Query
--From	sys.dm_exec_query_stats as qs
--cross apply sys.dm_exec_sql_text(qs.sql_handle) as st
--Order by
--		total_clr_time / execution_count desc

-- ##################################################################
-- # Retorna a Média das 5 Query's que mais consumiram tempo de CPU #
-- ##################################################################
--Select Top 10
--		total_worker_time / execution_count as [Avg CPU Time]
--,		Substring (st.text, (qs.statement_start_offset / 2) + 1,
--		((Case statement_end_offset
--			when -1 then datalength(st.text)
--			else qs.statement_end_offset 
--			end	-qs.statement_start_offset)/2) + 1) as Query		
--From	sys.dm_exec_query_stats as qs
--cross apply sys.dm_exec_sql_text(qs.sql_handle) as st
--Order by
--		total_worker_time / execution_count desc

-- ##############
-- # Auxiliares #
-- ##############
--sp_who2
--select * from sysperfinfo -- Informações de Performance
--select * from sys.sysprocesses
--Select * From sys.dm_exec_query_stats
--Select * From sys.dm_exec_sql_text
--Select * From sys.sysprocesses
--Select * From sys.sysprocesses as ps 
	--cross apply sys.dm_exec_sql_text(ps.sql_handle) as st