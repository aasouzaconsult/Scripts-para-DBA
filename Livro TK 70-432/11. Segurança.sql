EXEC sp_configure 'show advanced options',1
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sp_configure
GO
EXEC sp_configure 'Ad Hoc Distributed Queries',0
EXEC sp_configure 'clr enabled',0
EXEC sp_configure 'cross db ownership chaining',0
EXEC sp_configure 'Ole Automation Procedures',0
EXEC sp_configure 'SQL Mail XPs',0
EXEC sp_configure 'xp_cmdshell',0
GO
RECONFIGURE WITH OVERRIDE
GO

--Brackets are required due to the rules for identifiers
CREATE LOGIN [HOTEK2\TestAccount] FROM WINDOWS
GO

CREATE LOGIN Test WITH PASSWORD  = '123456'
CREATE LOGIN Test2 WITH PASSWORD = '123456'
GO
USE AdventureWorks
GO
CREATE USER Test FOR LOGIN Test
CREATE USER Test2 FOR LOGIN Test2
GO

USE AdventureWorks
GO
CREATE USER TestUser WITHOUT LOGIN
GO

-- Alterando Esquema do Usuario
ALTER USER Test2 WITH DEFAULT_SCHEMA = Test

--Instance level principals.
SELECT * FROM sys.asymmetric_keys
SELECT * FROM sys.certificates
SELECT * FROM sys.credentials
SELECT * FROM sys.linked_logins
SELECT * FROM sys.remote_logins
SELECT * FROM sys.server_principals
SELECT * FROM sys.server_role_members
SELECT * FROM sys.sql_logins
SELECT * FROM sys.endpoints
GO

--Database level principals.
SELECT * FROM sys.database_principals
SELECT * FROM sys.database_role_members
GO

ALTER LOGIN AlexSouza WITH NAME = Souza
GO

--Metadata security
--Check your user execution context
SELECT SUSER_SNAME(), USER_NAME()
GO

USE AdventureWorks
GO

--View the list of objects in the database
SELECT * FROM sys.objects
GO

--Change user context and view the list of objects
EXECUTE AS USER = 'Test'
GO
SELECT SUSER_SNAME(), USER_NAME()
GO
SELECT * FROM sys.objects
GO
REVERT
GO
SELECT SUSER_SNAME(), USER_NAME()
GO

GRANT SELECT ON Production.Document TO Test
GO

EXECUTE AS USER = 'Test'
GO
SELECT * FROM sys.objects
SELECT DocumentNode, Title, FileName FROM Production.Document
REVERT
GO

--Schema scoped permission
GRANT SELECT ON SCHEMA::Production TO Test
GO

EXECUTE AS USER = 'Test'
GO
SELECT * FROM sys.objects
REVERT
GO

--Schema scoped permission
GRANT SELECT ON DATABASE::AdventureWorks TO Test
GO

EXECUTE AS USER = 'Test'
GO
SELECT * FROM sys.objects
REVERT
GO

--Remove the ability to view object metadata
DENY VIEW DEFINITION TO Test
GO

-- Permitindo visualizar os metadados
GRANT VIEW DEFINITION TO Test

--While the user can still select, they can not see anything from the catalog views
EXECUTE AS USER = 'Test'
GO
SELECT * FROM sys.objects
SELECT DocumentNode, Title, FileName FROM Production.Document
REVERT
GO

REVOKE VIEW DEFINITION FROM Test
GO

EXECUTE AS USER = 'Test'
GO
SELECT * FROM sys.objects
REVERT
GO

REVOKE SELECT ON DATABASE::AdventureWorks FROM Test
GO

EXECUTE AS USER = 'Test'
GO
SELECT * FROM sys.objects
REVERT
GO

REVOKE SELECT ON SCHEMA::Production FROM Test
GO

EXECUTE AS USER = 'Test'
GO
SELECT * FROM sys.objects
REVERT
GO

REVOKE SELECT ON Production.Document FROM Test
GO

EXECUTE AS USER = 'Test'
GO
SELECT * FROM sys.objects
REVERT
GO

SELECT SUSER_NAME()

USE DBTeste
GO

CREATE MASTER KEY ENCRYPTION BY PASSWORD = '123456'
GO

OPEN MASTER KEY DECRYPTION BY PASSWORD = '123456'
BACKUP MASTER KEY TO FILE = 'D:\Alex\Temp\Bkp_DBMasterKey_Banco_DBTeste.key'
    ENCRYPTION BY PASSWORD = '123456'
GO

CREATE CERTIFICATE Certificado_DBTeste WITH SUBJECT = 'Test Certificate'
GO

BACKUP CERTIFICATE Certificado_DBTeste TO FILE = 'D:\Alex\Temp\Bkp_Certificado_Banco_DBTeste.cer'
GO

--Create a user in the database mapped to the certificate
CREATE USER CertUser FROM CERTIFICATE Certificado_DBTeste
GO

CREATE USER Test2 FROM LOGIN Test2
CREATE USER Test FROM LOGIN Test

--Create a broken ownership chain
CREATE SCHEMA SignatureTest AUTHORIZATION Test2
GO

CREATE TABLE SignatureTest.TestTable
(ID     INT         IDENTITY(1,1),
Col1    VARCHAR(10) NOT NULL)
GO

INSERT INTO SignatureTest.TestTable
(Col1)
VALUES ('Row1'), ('Row2')
GO

--Create a procedures to access test table
CREATE PROCEDURE SignatureTest.asp_Proc1
AS
    SELECT ID, Col1 FROM SignatureTest.TestTable
GO

CREATE PROCEDURE dbo.asp_SignatureTest
AS
    EXEC SignatureTest.asp_Proc1
GO

GRANT EXECUTE ON dbo.asp_SignatureTest TO Test
GO

--Test procedure execution
EXECUTE AS USER = 'Test'
EXEC dbo.asp_SignatureTest
REVERT
GO

--Grant execute to the user mapped to the certificate
GRANT EXECUTE ON SignatureTest.asp_Proc1 TO CertUser
GO

--Sign the procedure with the certificate
ADD SIGNATURE TO dbo.asp_SignatureTest BY CERTIFICATE Certificado_DBTeste
GO

--Verify that Test can now select from the table
EXECUTE AS USER = 'Test'
EXEC dbo.asp_SignatureTest
REVERT
GO

--Verify that TestLogin can not directly execute Test.asp_Proc1
EXECUTE AS USER = 'Test'
EXEC SignatureTest.asp_Proc1
REVERT
GO

--Verify that TestLogin can not directly select from the table
EXECUTE AS USER = 'Test'
SELECT ID, Col1 FROM SignatureTest.TestTable
REVERT
GO

--Verify that you cannot impersonate the user mapped to the certificate
EXECUTE AS USER = 'CertUser'
GO

/**************************************
 ************ AUDITORIA ***************
 **************************************/

USE MASTER
GO
-- Auditoria de Servidor
CREATE SERVER AUDIT RestrictedAccessAudit
    TO APPLICATION_LOG
    WITH ( QUEUE_DELAY = 1000,  ON_FAILURE = CONTINUE);
GO
 
USE AdventureWorks
GO
CREATE DATABASE AUDIT SPECIFICATION EmployeePayrollAccess
FOR SERVER AUDIT RestrictedAccessAudit
    ADD (SELECT, INSERT, UPDATE, DELETE 
           ON HumanResources.EmployeePayHistory
           BY dbo)
    WITH (STATE = ON);
GO

-- Ativando a Auditoria de Servidor
USE MASTER
GO 
ALTER SERVER AUDIT RestrictedAccessAudit
WITH (STATE = ON);
GO
 
--Test audit
USE AdventureWorks
GO
SELECT * FROM HumanResources.EmployeePayHistory
GO

--Disable Server audit
USE MASTER
GO 
ALTER SERVER AUDIT RestrictedAccessAudit
WITH (STATE = OFF);
GO


/*****************************************
 ************ CRIPTOGRAFIA ***************
 *****************************************/

--Hash data
DECLARE @Hash varchar(100)
SELECT @Hash = 'Encrypted Text'
SELECT HashBytes('MD5', @Hash)
SELECT @Hash = 'Encrypted Text'
SELECT HashBytes('SHA', @Hash)
GO

DECLARE @Hash varchar(100)
SELECT @Hash = 'encrypted text'
SELECT HashBytes('SHA1', @Hash)
SELECT @Hash = 'ENCRYPTED TEXT'
SELECT HashBytes('SHA1', @Hash)
GO

--Passphrase
DECLARE @EncryptedText   VARBINARY(80)

SELECT @EncryptedText = EncryptByPassphrase('<EnterStrongPasswordHere>','Encrypted Text')

SELECT @EncryptedText, CAST(DecryptByPassPhrase('<EnterStrongPasswordHere>',@EncryptedText) AS VARCHAR(MAX))
GO

--Symmetric Key
USE AdventureWorks
GO
CREATE SYMMETRIC KEY TestSymmetricKey WITH ALGORITHM = RC4
    ENCRYPTION BY PASSWORD = '123456'
GO

SELECT * FROM sys.symmetric_keys
GO

--Symmetric key must be opened before being used
OPEN SYMMETRIC KEY TestSymmetricKey DECRYPTION BY PASSWORD = '123456'
GO

DECLARE @EncryptedText   VARBINARY(80)
SELECT  @EncryptedText = EncryptByKey(Key_GUID('TestSymmetricKey'),'Encrypted Text')
SELECT  @EncryptedText, Descriptografado = CAST(DecryptByKey(@EncryptedText) AS VARCHAR(30))
GO

CLOSE SYMMETRIC KEY TestSymmetricKey
GO


--Certificate
USE AdventureWorks
GO

CREATE TABLE dbo.CertificateEncryption
(ID         INT             IDENTITY(1,1),
SalesRep    VARCHAR(30)     NOT NULL,
SalesLead   VARBINARY(500)  NOT NULL)
GO

CREATE USER SalesRep1 WITHOUT LOGIN
GO

CREATE USER SalesRep2 WITHOUT LOGIN
GO

GRANT SELECT, INSERT ON dbo.CertificateEncryption TO SalesRep1
GO

GRANT SELECT, INSERT ON dbo.CertificateEncryption TO SalesRep2
GO

CREATE CERTIFICATE SalesRep1Cert AUTHORIZATION SalesRep1
    WITH SUBJECT = 'SalesRep 1 certificate'
GO

CREATE CERTIFICATE SalesRep2Cert AUTHORIZATION SalesRep2
    WITH SUBJECT = 'SalesRep 2 certificate'
GO

SELECT * FROM sys.certificates
GO

EXECUTE AS USER='SalesRep1'
GO

INSERT INTO dbo.CertificateEncryption
(SalesRep, SalesLead)
VALUES('SalesRep1',EncryptByCert(Cert_ID('SalesRep1Cert'), 'Fabrikam'))
GO

REVERT
GO

EXECUTE AS USER='SalesRep2'
GO

INSERT INTO dbo.CertificateEncryption
(SalesRep, SalesLead)
VALUES('SalesRep2',EncryptByCert(Cert_ID('SalesRep2Cert'), 'Contoso'))
GO

REVERT
GO

SELECT ID, SalesRep, SalesLead
FROM dbo.CertificateEncryption
GO

EXECUTE AS USER='SalesRep1'
GO

SELECT ID, SalesRep, SalesLead, CAST(DecryptByCert(Cert_Id('SalesRep1Cert'),
    SalesLead) AS VARCHAR(MAX))
FROM dbo.CertificateEncryption
GO

REVERT
GO

EXECUTE AS USER='SalesRep2'
GO

SELECT ID, SalesRep, SalesLead, CAST(DecryptByCert(Cert_Id('SalesRep2Cert'),
    SalesLead) AS VARCHAR(MAX))
FROM dbo.CertificateEncryption
GO

REVERT
GO

/************************************
 **** Transparent Data Encryption ***
 ************************************/
USE master
GO

CREATE MASTER KEY ENCRYPTION BY PASSWORD = '123456'
GO

CREATE CERTIFICATE ServerCert WITH SUBJECT = 'My Server Cert for TDE'
GO

BACKUP CERTIFICATE ServerCert TO FILE = 'D:\Alex\Temp\bkp_servercert.cer'
WITH PRIVATE KEY (FILE = 'D:\Alex\Temp\servercert1.key',
    ENCRYPTION BY PASSWORD = '123456')
GO

USE AdventureWorks
GO

-- TDE (Chave de Criptografia)
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_128
ENCRYPTION BY SERVER CERTIFICATE ServerCert
GO

-- Ativa o banco para criptografia
ALTER DATABASE AdventureWorks
SET ENCRYPTION ON
GO
