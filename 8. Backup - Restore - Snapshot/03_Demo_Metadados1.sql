--DEMO PARA METADADOS BACKUPSET, RESTOREHISTORY E BACKUPMEDIAFAMILY

--BACKUPSET

--TUDO FROM BACKUPSET
SELECT * FROM MSDB..BACKUPSET

--UM POUCO MELHOR
SELECT backup_set_id
	   ,database_name
	   ,user_name
	   ,backup_start_date
	   ,backup_finish_date
	   ,CASE type
			WHEN 'D' THEN 'Full'
			WHEN 'L' THEN 'Log'
			WHEN 'I' THEN 'Differential'
		END AS 'Backup type'
	   ,compatibility_Level
	   ,CAST(backup_size / 1024 as INT) AS 'Backup Size(KB)'
	   ,CAST(compressed_backup_size / 1024 as INT) AS  'Compressed(KB)'
	   ,server_name
	   ,recovery_model
  FROM MSDB..backupset


--ONDE ESTÃO MEUS BACKUPS (BACKUPMEDIAFAMILY)
SELECT * FROM MSDB..backupmediafamily

--INFORMANDO ALGO UM POUCO MELHOR...
SELECT	bs.database_name
		,bs.backup_finish_date
		,bs.user_name
		,CASE bs.type
			WHEN 'D' THEN 'Full'
			WHEN 'L' THEN 'Log'
			WHEN 'I' THEN 'Differential'
		END AS 'Backup type'
		,bmf.physical_device_name
  FROM MSDB..backupmediafamily bmf
 INNER JOIN MSDB..backupset bs
    ON bmf.media_set_id = bs.media_set_id
 WHERE backup_finish_date BETWEEN '2012-12-04 23:59:20.000' AND '2012-12-05 01:19:59.000'
 ORDER BY bs.backup_finish_date desc


SELECT * FROM MSDB..backupfile --Informações sobre os arquivos de dados e log dentro do backup
SELECT * FROM MSDB..backupfilegroup --informações sobre os filegroups dentro dos arquivos de backup
SELECT * FROM MSDB..backupmediaset --informações sobre as midias de backup



--E OS RESTORES???
--TAMBÉM TEM ALGO PRA ELES
--SITUAÇÃO HIPOTÉTICA DE COMPROVAÇÃO DE RESTORE... 

SELECT * FROM MSDB..restorefile
SELECT * FROM MSDB..restorehistory

   
RESTORE FILELISTONLY FROM DISK = 'C:\temp\SQLServerRS\Backup\BKP_SQLSERVER_RS_Dec420121159PM_FULL.bak'

--SQLSERVER_RS	C:\temp\SQLServerRS\Dados\SQLSERVER_RS.mdf
--SQLSERVER_RS_LOG	C:\temp\SQLServerRS\Log\SQLSERVER_RS_Log.ldf


RESTORE DATABASE SQLSERVER_RS_RESTORE
   FROM DISK = 'C:\temp\SQLServerRS\Backup\BKP_SQLSERVER_RS_Dec420121159PM_FULL.bak'
 
   WITH RECOVERY
  ,MOVE 'SQLSERVER_RS' TO 'C:\temp\SQLServerRS\Dados\SQLSERVER_RS_RESTORE.mdf'
  ,MOVE 'SQLSERVER_RS_LOG' TO 'C:\temp\SQLServerRS\Log\SQLSERVER_RS_RESTORE_Log.ldf'

SELECT * 
  FROM MSDB..restorefile
SELECT * 
  FROM MSDB..restorehistory
