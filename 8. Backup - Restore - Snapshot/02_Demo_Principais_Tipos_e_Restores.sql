--CRIA BANCO PARA EXECUÇÃO DOS BACKUPS
IF EXISTS (SELECT NULL FROM SYS.DATABASES WHERE NAME = 'SQLSERVER_RS_PTBKP')
           DROP DATABASE SQLSERVER_RS_PTBKP
CREATE DATABASE SQLSERVER_RS_PTBKP
ON PRIMARY
(NAME='SQLSERVER_RS_PTBKP', FILENAME='C:\temp\SQLServerRS\Dados\SQLSERVER_RS_PTBKP.mdf')
LOG ON
(NAME = 'SQLSERVER_RS_PTBKP_LOG', FILENAME = 'C:\temp\SQLServerRS\Log\SQLSERVER_RS_PTBKP_Log.ldf')
GO

--ADICIONA UM NOVO FILEGROUP AO BANCO
ALTER DATABASE SQLSERVER_RS_PTBKP ADD FILEGROUP [LEITURA] 
GO

--CRIA UM ARQUIVO ASSOCIADO AO FILEGROUP ADICIONADO
ALTER DATABASE SQLSERVER_RS_PTBKP
  ADD FILE ( NAME = 'Leitura', FILENAME = 'C:\temp\SQLServerRS\Dados\SQLSERVER_RS_PTBK.ndf') 
   TO FILEGROUP LEITURA
GO

--ALTERA O FILEGROUP PARA READONLY
ALTER DATABASE SQLSERVER_RS_PTBKP MODIFY FILEGROUP LEITURA READONLY
GO



--BACKUP FULL
BACKUP DATABASE SQLSERVER_RS_PTBKP
    TO DISK = 'C:\TEMP\SQLServerRS\Backup\PTBKP\SQLSERVER_RS_PTBKP.dat'

--BACKUP DIFFERENTIAL
BACKUP DATABASE SQLSERVER_RS_PTBKP
    TO DISK = 'C:\TEMP\SQLServerRS\Backup\PTBKP\SQLSERVER_RS_PTBKP.dat'
  WITH DIFFERENTIAL

--BACKUP T-LOG
BACKUP LOG SQLSERVER_RS_PTBKP
    TO DISK = 'C:\TEMP\SQLServerRS\Backup\PTBKP\SQLSERVER_RS_PTBKP.dat'


--FORAM GERADOS TODOS OS BACKUPS PARA O MESMO ARQUIVO....   E AGORA?


***************************************************************************************************
***************************************************************************************************
***************************************************************************************************
------------------                   OPÇÕES DE RESTORE                         --------------------
***************************************************************************************************
***************************************************************************************************
***************************************************************************************************


--VERIFAR BACKUPS DENTRO DO BACKUP
RESTORE HEADERONLY FROM DISK =  'C:\TEMP\SQLServerRS\Backup\PTBKP\SQLSERVER_RS_PTBKP.dat'

--VERIFICAR ARQUIVOS DE DADOS E LOG DENTRO DOS ARQUIVOS DE BACKUP
RESTORE FILELISTONLY FROM DISK = 'C:\TEMP\SQLServerRS\Backup\PTBKP\SQLSERVER_RS_PTBKP.dat' WITH FILE = X

--VERIFICAR INTEGRIDADE DO BACKUP
RESTORE VERIFYONLY FROM DISK = 'C:\TEMP\SQLServerRS\Backup\PTBKP\SQLSERVER_RS_PTBKP.dat' WITH FILE = 2

--INFORMAÇÕES SOBRE A MÍDIA DE BACKUP
RESTORE LABELONLY FROM DISK = 'C:\TEMP\SQLServerRS\Backup\PTBKP\SQLSERVER_RS_PTBKP.dat' WITH FILE = 1

--RESTORE REWINDONLY (UTILIZADO SOMENTE COM O DEVICE TIPO "TAPE")


***************************************************************************************************
--BACKUP PARTIAL
BACKUP DATABASE SQLSERVER_RS_PTBKP
 READ_WRITE_FILEGROUPS
  TO DISK = 'C:\TEMP\SQLServerRS\Backup\PTBKP\SQLSERVER_RS_PTBKP.dat'
  
--BACKUP FILEGROUP	
BACKUP DATABASE SQLSERVER_RS_PTBKP
       FILEGROUP =	'LEITURA'
	TO DISK = 'C:\TEMP\SQLServerRS\Backup\PTBKP\SQLSERVER_RS_PTBKP.dat'
***************************************************************************************************       