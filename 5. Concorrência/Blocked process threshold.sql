-- blocked process threshold
sp_configure 'show advanced options',1 ; 
GO 
RECONFIGURE; 
GO 
sp_configure 'blocked process threshold',5 ; -- threshold  = 5 segundos
GO 
RECONFIGURE; 
GO


-- Profiler - Errors and Warnings:Blocked process report

-- ServerSide trace para monitorar evento...
declare @rc int
declare @TraceID int
declare @maxfilesize bigint
set @maxfilesize = 50 
exec @rc = sp_trace_create @TraceID output, 2, N'C:\Fabiano\Trabalho\WebCasts, Artigos e Palestras\WebCast SrNimbus - DBA CheckList\BlockedProcessTrace', @maxfilesize, NULL 
if (@rc != 0) goto error
declare @on bit
set @on = 1
exec sp_trace_setevent @TraceID, 137, 15, @on
exec sp_trace_setevent @TraceID, 137, 1, @on
exec sp_trace_setevent @TraceID, 137, 13, @on
declare @intfilter int
declare @bigintfilter bigint
exec sp_trace_setstatus @TraceID, 1
select TraceID=@TraceID
goto finish
error: 
select ErrorCode=@rc
finish: 
go
/*
  Script úteis...
    -- Stop
  sp_trace_setstatus @traceid =  2, @status = 0
  -- Start
  sp_trace_setstatus @traceid =  2, @status = 1
  -- Delete
  sp_trace_setstatus @traceid =  2, @status = 2

  SELECT * FROM :: fn_trace_getinfo(DEFAULT)

  SELECT cast(TextData as xml)
    FROM fn_trace_gettable(N'C:\Fabiano\Trabalho\WebCasts, Artigos e Palestras\WebCast SrNimbus - DBA CheckList\BlockedProcessTrace.trc', default)
   WHERE eventclass = 137

*/
-- Ler o trace
SELECT cast(TextData as xml)
  FROM fn_trace_gettable(N'C:\Fabiano\Trabalho\WebCasts, Artigos e Palestras\WebCast SrNimbus - DBA CheckList\BlockedProcessTrace.trc', default)
 WHERE eventclass = 137
    AND EndTime > DateAdd(minute, -10, GetDate()) -- Se o lock ocorreu nos últimos 10 mins
GO

-- Criar JOB para gerar enviar e-mail com informação do block
DECLARE @Col1 VarChar(MAX)
SELECT @Col1 = TextData
  FROM fn_trace_gettable(N'C:\Fabiano\Trabalho\WebCasts, Artigos e Palestras\WebCast SrNimbus - DBA CheckList\BlockedProcessTrace.trc', default)
 WHERE eventclass = 137
   AND EndTime > DateAdd(minute, -10, GetDate()) -- Se o lock ocorreu nos últimos 10 mins
IF @@ROWCOUNT > 0
BEGIN
  RAISERROR (@Col1, 0, 1) WITH LOG
  -- Envio de e-mail
  EXEC msdb.dbo.sp_send_dbmail @profile_name = 'ProfileFabiano',
                               @recipients   = 'fabianonevesamorim@hotmail.com',
                               @subject      = 'Blocked process threshold',
                               @body         = @Col1
END