BACKUP DATABASE AdventureWorks
    TO DISK = 'c:\test\AdventureWorks_1.bak'
    MIRROR TO DISK = 'c:\test\AdventureWorks_2.bak'
    WITH COMPRESSION, INIT, FORMAT, CHECKSUM, STOP_ON_ERROR
GO

USE AdventureWorks
GO

INSERT INTO HumanResources.Department
(Name, GroupName)
VALUES('Test1', 'Research and Development')
GO

BACKUP LOG AdventureWorks
TO DISK = 'c:\test\AdventureWorks_1.trn'
WITH COMPRESSION, INIT, CHECKSUM, STOP_ON_ERROR
GO

INSERT INTO HumanResources.Department
(Name, GroupName)
VALUES('Test2', 'Research and Development')
GO

BACKUP LOG AdventureWorks
TO DISK = 'c:\test\AdventureWorks_2.trn'
WITH COMPRESSION, INIT, CHECKSUM, STOP_ON_ERROR
GO

INSERT INTO HumanResources.Department
(Name, GroupName)
VALUES('Test3', 'Research and Development')
GO

BACKUP DATABASE AdventureWorks
    TO DISK = 'c:\test\AdventureWorks_1.dif'
    MIRROR TO DISK = 'c:\test\AdventureWorks_2.dif'
    WITH DIFFERENTIAL, COMPRESSION, INIT, FORMAT, CHECKSUM, STOP_ON_ERROR
GO

USE AdventureWorks
GO

INSERT INTO HumanResources.Department
(Name, GroupName)
VALUES('Test4', 'Research and Development')
GO

BACKUP LOG AdventureWorks
TO DISK = 'c:\test\AdventureWorks_3.trn'
WITH COMPRESSION, INIT, NO_TRUNCATE
GO

RESTORE DATABASE AdventureWorks
    FROM DISK = 'c:\test\AdventureWorks_1.bak'
    WITH STANDBY = 'c:\test\AdventureWorks.stn'
GO

RESTORE DATABASE AdventureWorks
    FROM DISK = 'c:\test\AdventureWorks_1.dif'
    WITH STANDBY = 'c:\test\AdventureWorks.stn'
GO

RESTORE DATABASE AdventureWorks
WITH RECOVERY
GO

RESTORE DATABASE AdventureWorks
    FROM DISK = 'c:\test\AdventureWorks_1.bak'
    WITH STANDBY = 'c:\test\AdventureWorks.stn',
        REPLACE
GO

RESTORE DATABASE AdventureWorks
    FROM DISK = 'c:\test\AdventureWorks_1.trn'
    WITH STANDBY = 'c:\test\AdventureWorks.stn'
GO

RESTORE DATABASE AdventureWorks
    FROM DISK = 'c:\test\AdventureWorks_2.trn'
    WITH STANDBY = 'c:\test\AdventureWorks.stn'
GO

RESTORE DATABASE AdventureWorks
    FROM DISK = 'c:\test\AdventureWorks_3.trn'
    WITH STANDBY = 'c:\test\AdventureWorks.stn'
GO

RESTORE DATABASE AdventureWorks
WITH RECOVERY
GO

CREATE DATABASE AdventureWorksSnap ON  
(NAME = N'AdventureWorks_Data', FILENAME = N'D:\Alex\Temp\AdventureWorks.ds')
,(NAME = N'S AdventureWorksFT' , FILENAME = N'D:\Alex\Temp\AdventureWorks2.ds')
AS SNAPSHOT OF AdventureWorks
GO

SELECT * FROM AdventureWorks.sys.database_files
SELECT * FROM AdventureWorksSnap.sys.database_files
SELECT * FROM master.sys.databases
GO

/************************************************************/
-- Chave Mestra de Serviço (É criada quando a instancia é iniciada)
BACKUP SERVICE MASTER KEY TO FILE = 'D:\Alex\Temp\Bkp_ServiceMasterKey_SQL2008.mk'
ENCRYPTION BY PASSWORD = 'backup12345'

-- Chave Mestra de Banco de Dados (DMK) - São criadas antes de um Certificado e é
-- criado manualmente.
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'senha'

-- Depois de Criado uma Chave para o Banco de Dados faça o Backup
USE <nome do banco>
OPEN MASTER KEY DECRYPTION BY PASSWORD = 'O password da chave do banco'

BACKUP MASTER KEY TO FILE = 'D:\Alex\Temp\Bkp_DBMasterKey_Banco.mk'
ENCRYPTION BY PASSWORD = 'backup12345'
