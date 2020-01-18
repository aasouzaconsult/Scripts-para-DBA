DROP TABLE UserConnectionDatabaseUse;

CREATE TABLE UserConnectionDatabaseUse
(date_time datetime NOT NULL,
 login_time datetime NOT NULL, 
 minutes_connected smallint NOT NULL, 
 last_batch datetime NOT NULL, 
 minutes_idle smallint NOT NULL,
 database_name varchar(50) NOT NULL,
 loginame varchar(50) NOT NULL,
 hostname varchar(50) NOT NULL)
go

-----------------------------------------------------------------------------------------------------

USE [msdb]
GO
/****** Object:  Job [Database Connections]    Script Date: 08/01/2007 15:29:24 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 08/01/2007 15:29:25 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Database Connections', 
        @enabled=1, 
        @notify_level_eventlog=0, 
        @notify_level_email=0, 
        @notify_level_netsend=0, 
        @notify_level_page=0, 
        @delete_level=0, 
        @description=N'No description available.', 
        @category_name=N'[Uncategorized (Local)]', 
        @owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Insert UserConnectionDatabaseUse]    Script Date: 08/01/2007 15:29:25 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Insert UserConnectionDatabaseUse', 
        @step_id=1, 
        @cmdexec_success_code=0, 
        @on_success_action=1, 
        @on_success_step_id=0, 
        @on_fail_action=2, 
        @on_fail_step_id=0, 
        @retry_attempts=0, 
        @retry_interval=0, 
        @os_run_priority=0, @subsystem=N'TSQL', 

        @command=N'insert into master..UserConnectionDatabaseUse
select  getdate() as date_time,
        login_time, 
        datediff(mi, login_time, getdate()) as minutes_connected,
        last_batch, 
        datediff(mi, last_batch, getdate()) as minutes_idle,
        db_name(dbid) as database_name, 
        loginame, 
        hostname
from master..sysprocesses
where spid > 50 and
      loginame <> ''DOMAIN\alex.rosa''
order by 2
', 

        @database_name=N'master', 
        @flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 1 Minute', 
        @enabled=1, 
        @freq_type=4, 
        @freq_interval=1, 
        @freq_subday_type=4, 
        @freq_subday_interval=1, 
        @freq_relative_interval=0, 
        @freq_recurrence_factor=0, 
        @active_start_date=20070801, 
        @active_end_date=99991231, 
        @active_start_time=0, 
        @active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

-----------------------------------------------------------------------------------------------------

use master;

select * 
from UserConnectionDatabaseUse
order by 1

select  spid,
        login_time, 
        datediff(hh, login_time, getdate()) as hours_connected,
        last_batch, 
        datediff(hh, last_batch, getdate()) as hours_idle,
        db_name(dbid) as database_name,
        loginame, 
        hostname,
        program_name
from master..sysprocesses
where spid > 50 and loginame <> 'A-SRV7\sqldesenv' and
      datediff(hh, login_time, getdate()) > 24
order by 2


-- List all connections grouped by (loginame, database_name, hostname, login_time)
select loginame, database_name, hostname, login_time
from master.dbo.UserConnectionDatabaseUse
group by loginame, database_name, hostname, login_time
order by 2,3,4


-- List the last connection grouped by (database_name)
select b.name as database_name, min(date_time) as first_login, max(date_time) as last_login,
        datediff(dd, max(date_time), getdate()) as days_withnoaccess
from master.dbo.UserConnectionDatabaseUse a
right join master.dbo.sysdatabases b on a.database_name = b.name
group by b.name
order by 1,3



-------------------------------------------------------------------------------------------------
