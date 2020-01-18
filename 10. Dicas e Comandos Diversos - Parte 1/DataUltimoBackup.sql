--Listar os últimos backups realizados com SUCESSO

SELECT  
		bs.database_name AS Nome_Banco
,		CASE bs.type
			WHEN 'D' THEN 'DADOS'
			WHEN 'L' THEN 'LOG'
		END AS Tipo_Backup
,		MAX(bs.backup_start_date) AS Data_Ultimo_Backup
FROM		master..sysdatabases sd
LEFT JOIN	msdb..backupset bs ON bs.database_name = sd.name
LEFT JOIN	msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
GROUP BY
	sd.name
,	bs.type
,	bs.database_name
ORDER BY
    Nome_Banco
,	Data_Ultimo_Backup


