SELECT * INTO dbo.TK432BaselineTrace
FROM fn_trace_gettable('D:\Rastreamento.trc', default);
GO

Drop table dbo.TK432BaselineTrace

SELECT * FROM dbo.TK432BaselineTrace
GO