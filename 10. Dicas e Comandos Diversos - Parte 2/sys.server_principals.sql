SELECT p.principal_id , p.name, p.type, p.is_disabled, l.hasaccess, l.denylogin 
FROM sys.server_principals p LEFT JOIN sys.syslogins l
ON ( l.name = p.name )
WHERE p.type IN ( 'S', 'G', 'U' ) 



