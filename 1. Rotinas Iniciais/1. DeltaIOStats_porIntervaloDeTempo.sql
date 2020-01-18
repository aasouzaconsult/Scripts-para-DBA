--http://jongurgul.com/blog/delta-cumulative-io-stats/

SELECT GETDATE() [dtStart],iovfs.*,mf.[name],mf.[type_desc] INTO #dm_io_virtual_file_stats_start 
FROM sys.master_files mf INNER JOIN sys.dm_io_virtual_file_stats(NULL,NULL) iovfs
ON mf.[database_id] = iovfs.[database_id] and mf.[file_id] = iovfs.[file_id]
WAITFOR DELAY '00:05:00'; -- INFORME UM INTERVALOR

SELECT 
DB_NAME(t1.[database_id]) [DatabaseName]
,t1.[file_id] [FileID]
,t1.[name] [LogicalName]
,t1.[type_desc] [FileType]
,SUM(t2.[num_of_bytes_read])-SUM(t1.[num_of_bytes_read]) [Read_bytes]
,SUM(t2.[num_of_bytes_written])-SUM(t1.[num_of_bytes_written]) [Written_bytes]
,(SUM(t2.[num_of_bytes_read])-SUM(t1. [num_of_bytes_read]))/1048576 [Read_MiB]
,(SUM(t2.[num_of_bytes_written])-SUM(t1. [num_of_bytes_written]))/1048576 [Written_MiB]
,SUM(t2.[num_of_reads])-SUM(t1. [num_of_reads]) [Read_Count]
,SUM(t2.[num_of_writes])-SUM(t1. [num_of_writes]) [Write_Count]
,SUM(t2.[num_of_reads]+t2.[num_of_writes])-SUM(t1.[num_of_reads]+t1.[num_of_writes]) [IO_Count]
,CONVERT(DECIMAL (15,2),SUM(t1.[num_of_bytes_read])/(NULLIF(SUM(t1.[num_of_bytes_read]+t1.[num_of_bytes_written]),0)*0.01)) [Read_Percent]
,CONVERT(DECIMAL (15,2),SUM(t1.[num_of_bytes_written])/(NULLIF(SUM(t1.[num_of_bytes_read]+t1.[num_of_bytes_written]),0)*0.01)) [Write_Percent]
,CONVERT(DECIMAL (15,2),SUM(t2.[num_of_bytes_read]-t1.[num_of_bytes_read])/NULLIF((SUM(t2.[num_of_bytes_read]+t2.[num_of_bytes_written]-t1.[num_of_bytes_read]-t1.[num_of_bytes_written])*0.01),0)) [Read_Delta_Percent]
,CONVERT(DECIMAL (15,2),SUM(t2.[num_of_bytes_written]-t1.[num_of_bytes_written])/NULLIF((SUM(t2.[num_of_bytes_read]+t2.[num_of_bytes_written]-t1.[num_of_bytes_read]-t1.[num_of_bytes_written])*0.01),0)) [Write_Delta_Percent]
,CONVERT(DECIMAL (15,2),COALESCE(SUM(t1.[io_stall_read_ms])/NULLIF(SUM(t1.[num_of_reads]*1.0),0),0)) [AverageReadStall_ms]
,CONVERT(DECIMAL (15,2),COALESCE(SUM(t1.[io_stall_write_ms])/NULLIF(SUM(t1.[num_of_writes]*1.0),0),0)) [AverageWriteStall_ms]
,CONVERT(DECIMAL (15,2),COALESCE(SUM(t2.[io_stall_read_ms]-t1.[io_stall_read_ms])/NULLIF(SUM(t2.[num_of_reads]-t1.[num_of_reads]*1.0),0),0)) [AverageReadStall_Delta_ms]
,CONVERT(DECIMAL (15,2),COALESCE(SUM(t2.[io_stall_write_ms]-t1.[io_stall_write_ms])/NULLIF(SUM(t2.[num_of_writes]-t1.[num_of_writes]*1.0),0),0)) [AverageWriteStall_Delta_ms]
,t1.dtStart
,GETDATE() dtEnd
FROM #dm_io_virtual_file_stats_start t1 
INNER JOIN 
(SELECT iovfs.*,mf.[name],mf.[type_desc] FROM sys.master_files mf INNER JOIN sys.dm_io_virtual_file_stats(NULL,NULL) iovfs
ON mf.[database_id] = iovfs.[database_id] AND mf.[file_id] = iovfs.[file_id]
) t2 ON t1.[database_id] = t2.[database_id] AND t1.[file_id] = t2.[file_id]
GROUP BY t1.[dtStart],DB_NAME(t1.[database_id]),t1.[file_id],t1.[name],t1.[type_desc];
DROP TABLE #dm_io_virtual_file_stats_start;

-- https://msdn.microsoft.com/pt-br/library/ms190326.aspx (sys.dm_io_virtual_file_stats)
-- https://msdn.microsoft.com/pt-br/library/ms186782.aspx (sys.master_files)