--Executar leitura de um arquivo de TRACE
SELECT * FROM ::fn_trace_gettable('C:\Trace\Trace_SQL.trc', default)
order by starttime
GO