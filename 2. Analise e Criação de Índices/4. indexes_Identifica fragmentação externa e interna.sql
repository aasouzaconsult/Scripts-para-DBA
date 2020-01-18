SELECT OBJECT_NAME(dt.object_id), si.name, dt.avg_fragmentation_in_percent, dt.avg_page_space_used_in_percent
FROM 
	(SELECT object_id, index_id, avg_fragmentation_in_percent, avg_page_space_used_in_percent
	 FROM sys.dm_db_index_physical_stats (DB_ID('TopManager'), NULL, NULL, NULL, 'DETAILED')
	 WHERE index_id <> 0) AS dt
INNER JOIN sys.indexes si ON si.object_id = dt.object_ID
	 AND si.index_id = dt.index_id
