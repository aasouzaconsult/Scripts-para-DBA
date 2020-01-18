--STOP: Script para finalizar o trace

------------------------------------------------------
-- STOP: Trace
------------------------------------------------------
declare @TraceID int
declare @filename nvarchar(512)

------------------------------------------------------
-- PARAMETROS
--  @filename = Nome do arquivo do Trace (.TRC)
------------------------------------------------------
set @filename = N'C:\QueryTimeout.trc'

select @TraceID = id from sys.traces where path = @filename 

if @TraceID is NULL
BEGIN
	PRINT 'Trace nao encontrado. Path=' + @filename
	goto finish
END

exec sp_trace_setstatus @TraceID, 0
exec sp_trace_setstatus @TraceID, 2

select * from sys.traces where path is not null

finish:  

