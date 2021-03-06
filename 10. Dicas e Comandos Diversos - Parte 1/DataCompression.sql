--Procedure to estimate data compression
EXEC sp_estimate_data_compression_savings 'Production', 'WorkOrderRouting', NULL, NULL, 'ROW' ;

--Compress a table
USE [AdventureWorks]
GO
ALTER TABLE [Person].[Contact] REBUILD PARTITION = ALL
WITH (DATA_COMPRESSION = PAGE)

--Verify wich table is compressed
SELECT 
	OBJECT_NAME([object_id]) AS Table_Name, 
	data_compression_desc  
FROM 
	sys.partitions
WHERE
	data_compression_desc <> 'NONE'