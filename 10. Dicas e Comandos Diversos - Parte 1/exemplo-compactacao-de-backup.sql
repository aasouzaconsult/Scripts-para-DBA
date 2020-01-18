--Verificando a configuração atual do Backup compression default
SP_Configure

--Habilitando backup compression default
Exec SP_CONFIGURE 'backup compression default',1

--Desabilitando backup compression default
Exec SP_CONFIGURE 'backup compression default',0

--Realizando Backup
Backup Database Teste To Disk = 'C:\Teste.bak' 

--Realizando Backup Compactado
Backup Database Teste To Disk = 'C:\Teste-Compactado.bak' 
 With Compression

--Recuperando informações do Backup
RESTORE LABELONLY FROM DISK = 'C:\TESTE.BAK'

--Recuperando informações do Backup
RESTORE LABELONLY FROM DISK = 'C:\TESTE-COMPACTADO.BAK'

--Recuperando informações do Backup
SELECT * FROM msdb..backupfile
WHERE BACKUP_SET_ID=6