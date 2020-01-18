SELECT * 
FROM 
(SELECT user_seeks * avg_total_user_cost * (avg_user_impact * 0.01) AS 
index_advantage, migs.* FROM sys.dm_db_missing_index_group_stats migs) AS migs_adv 
INNER JOIN sys.dm_db_missing_index_groups AS mig ON migs_adv.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details AS mid ON mig.index_handle = mid.index_handle
ORDER BY migs_adv.index_advantage
GO

SELECT * FROM sys.dm_exec_requests CROSS APPLY sys.dm_exec_query_plan(plan_handle)
    CROSS APPLY sys.dm_exec_sql_text(sql_handle)
GO

SELECT * FROM sys.dm_exec_query_stats CROSS APPLY sys.dm_exec_query_plan(plan_handle)
    CROSS APPLY sys.dm_exec_sql_text(sql_handle)
GO

SELECT City, PostalCode, AddressLine1 
FROM Person.Address 
WHERE City = 'Seattle'
GO
SELECT City, PostalCode, AddressLine1 
FROM Person.Address 
WHERE City = 'Seattle' AND AdressLine2 IS NOT NULL
GO
SELECT City, PostalCode, AddressLine1 
FROM Person.Address 
WHERE City LIKE 'D%'
GO
SELECT City, PostalCode, AddressLine1 
FROM Person.Address 
WHERE City LIKE 'Atlan%'
go 100
