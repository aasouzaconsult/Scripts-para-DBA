--Verificar qual o database mais utilizado na instância
SELECT 
    COUNT(*) AS cached_pages_count,
    CASE database_id 
    WHEN 32767 THEN 'ResourceDb' 
    ELSE DB_NAME(database_id) 
    END AS Database_name
FROM 
    sys.dm_os_buffer_descriptors
GROUP BY 
    DB_NAME(database_id),
    database_id
ORDER BY 
    cached_pages_count DESC;