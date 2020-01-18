SELECT		dp.NAME AS principal_name
,			dp.type_desc AS principal_type_desc
,			o.NAME AS [object_name]
,			p.permission_name
,			p.state_desc AS permission_state_desc
FROM		sys.database_permissions p
LEFT JOIN	sys.all_objects o ON p.major_id = o.[OBJECT_ID]     
INNER JOIN  sys.database_principals dp ON p.grantee_principal_id = dp.principal_id

-- Com esse script consegui trazer todas as permissões que cada usuário possuía dentro do banco de dados, 