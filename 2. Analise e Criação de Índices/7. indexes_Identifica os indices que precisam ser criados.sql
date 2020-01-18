SELECT	index_advantage AS Advantage -- Vantagem percentual para as queries que precisaram destes índices.Na linha 1, a vantagem é de (718 + 100) / 100, 818%.
,		mid.object_id AS ID
,		mid.Statement AS TableStatement
,		mid.Equality_columns AS Equality
,		mid.inequality_columns AS Inequality
,		included_columns AS Included
,		mig.index_handle AS Handler 
FROM(
	SELECT (user_seeks + user_scans) * avg_total_user_cost * (avg_user_impact * 0.01) AS index_advantage, migs.* 
		FROM sys.dm_db_missing_index_group_stats migs 
	) AS migs_adv, 
   sys.dm_db_missing_index_groups mig, 
   sys.dm_db_missing_index_details mid 
WHERE	migs_adv.group_handle = mig.index_group_handle 
and		mig.index_handle = mid.index_handle
and		index_advantage > 0
ORDER BY 
		migs_adv.index_advantage DESC 
