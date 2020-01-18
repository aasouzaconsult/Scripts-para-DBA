USE master;
GO
CREATE MASTER KEY 
ENCRYPTION BY PASSWORD = 'ABC123';
go

CREATE CERTIFICATE CertLaboratorio
WITH SUBJECT = 'Certificado - Criptografia - Laboratorio'
go

BACKUP CERTIFICATE CertLaboratorio 
 TO FILE = 'c:\CertLaboratorio.cer'
 WITH PRIVATE KEY ( FILE = 'c:\CertLaboratorio.pvk' , 
 ENCRYPTION BY PASSWORD = 'ABC123');

USE LABORATORIO
GO

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_128
ENCRYPTION BY SERVER CERTIFICATE CertLaboratorio
GO
    
ALTER DATABASE Laboratorio
SET ENCRYPTION ON
GO

select * from sys.dm_database_encryption_keys
