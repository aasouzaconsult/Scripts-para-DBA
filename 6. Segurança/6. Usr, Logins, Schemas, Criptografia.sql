/**********
 * LOGINS *
 **********/
CREATE LOGIN [AAS\Souza] FROM WINDOWS -- Criando Login do Windows
CREATE LOGIN [AlexTeste] FROM WINDOWS WITH DEFAULT_DATABASE=[DB_TK432], DEFAULT_LANGUAGE=[Português (Brasil)]

CREATE LOGIN Souza With Password = 'Souza' -- Criando Login do SQL Server

/************
 * USUÁRIOS *
 ************/
CREATE USER SouzaWin FOR LOGIN [AAS\Souza] -- Para Login do Windows

CREATE USER Souza FOR LOGIN Souza -- Para Login do SQL Server

/*********
 * ROLES *
 *********/
-- Associando um usuário a uma Database Role (Funções de Banco de Dados)
EXEC sp_addrolemember 'db_owner', 'Souza'

-- Associando um usuário a uma Server Role (Funções de Servidor)
EXEC master..sp_addsrvrolemember @loginame = 'Souza', @rolename = 'sysadmin'

/***********
 * SCHEMAS *
 ***********/
CREATE SCHEMA <schema name> AUTHORIZATION <owner name>
--Exemplo:
CREATE SCHEMA Sc_Teste AUTHORIZATION Souza
go

-- Troca o contexto para o usuario Souza
EXECUTE AS LOGIN = 'Souza'

Use DB_TK432
CREATE TABLE [Sc_Teste].[Table_2](
	[CdTeste] [smallint] IDENTITY(1,1) NOT NULL,
	[NmTeste] [varchar](50) NULL
) ON [FG1]

--Populando
INSERT INTO Sc_Teste.Table_2 VALUES ('TESTE 1');
INSERT INTO Sc_Teste.Table_2 VALUES ('TESTE 2');

-- Visualizando dados da tabela
SELECT * FROM Sc_Teste.Table_2
-- Visualizando as propriedades da tabelas
SELECT * FROM sys.columns WHERE object_id = object_id('Sc_Teste.Table_2');

--Permitindo SELECT no Schema: Sc_Teste para o usuário: Leitura
GRANT SELECT ON SCHEMA::Sc_Teste TO Leitura;
--Permitindo visualização das propriedades da tabela ao usr: Leitura
GRANT VIEW DEFINITION ON Sc_Teste.Table_2 TO Leitura;

-- Troca o contexto para o usuario Leitura
EXECUTE AS LOGIN = 'Leitura'

-- Visualizando dados da tabela
SELECT * FROM Sc_Teste.Table_2
-- Visualizando as propriedades da tabelas
SELECT * FROM sys.columns WHERE object_id = object_id('Sc_Teste.Table_2');

-- Volta o contexto para o usuário que abriu a sessão
REVERT;

/*****************************************************
 * CRIPTOGRAFIA USANDO CERTIFICADO E CHAVE SIMETRICA *
 *****************************************************/
-- ************************ 
-- ** Usando Certificado **
-- ************************ 
USE AdventureWorks;
-- O Objetivo é criptografar os dados da Coluna NationalIDNumber
Select * From HumanResources.Employee

-- Criando uma Coluna para o dado Criptografado
Alter table HumanResources.Employee
	Add EncryptedNationalIDNumber varbinary(128)
GO
Select EncryptedNationalIDNumber, * From HumanResources.Employee

-- Criando Certificado protegido por Senha
CREATE CERTIFICATE DemoCert
ENCRYPTION BY PASSWORD = 'DemoCert'
WITH SUBJECT = 'DemoCertificate'
GO
UPDATE HumanResources.Employee
SET EncryptedNationalIDNumber = ENCRYPTBYCERT(CERT_ID('DemoCert'), NationalIDNumber)
GO

-- Agora os dados da EncryptedNationalIDNumber estão Criptografados
Select EncryptedNationalIDNumber, * From HumanResources.Employee

-- Lendo os dados Criptografados
Select 
	NationalIDNumber
,	EncryptedNationalIDNumber
,	Descriptografado = CONVERT(nvarchar, DECRYPTBYCERT(CERT_ID('DemoCert'),
EncryptedNationalIDNumber, N'DemoCert'))
From HumanResources.Employee

ALTER TABLE HumanResources.Employee
	DROP COLUMN EncryptedNationalIDNumber 

-- ****************************
-- ** Usando Chave Simetrica **
-- ****************************
-- Cria database MASTER KEY para proteger a chave primária do Certificado
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'master'
GO
-- Criar um Certificado
CREATE CERTIFICATE HumanResources_Cert
WITH SUBJECT = 'Social Security Numbers'
GO

-- View do Sistema para ver os Certificados
Select * From Sys.Certificates

-- Fazendo um Backup do certificado: HumanResources_Cert
BACKUP CERTIFICATE HumanResources_Cert TO FILE = 'D:\HumanResources_Cert.cer'
WITH PRIVATE KEY (FILE = 'D:\HumanResources_Cert_Chave.pvk', ENCRYPTION BY PASSWORD = '@l3x');

-- Apagando o Certificado
DROP CERTIFICATE HumanResources_Cert

-- Restaurando o Backup do certificado: HumanResources_Cert
CREATE CERTIFICATE HumanResources_Cert
FROM FILE = 'D:\HumanResources_Cert.cer'
WITH PRIVATE KEY (FILE = 'D:\HumanResources_Cert_Chave.pvk', DECRYPTION BY PASSWORD = '@l3x'); 
GO

-- Criar Chave Simetrica
CREATE SYMMETRIC KEY SYM_Key_01
WITH ALGORITHM = AES_256 -- Não funciona com WindowsXP ou Windows 2000
ENCRYPTION BY CERTIFICATE HumanResources_Cert
GO

-- View do Sistema para ver os Certificados
Select * From Sys.Certificates
-- View do Sistema para as Chaves Simetricas
Select * From Sys.Symmetric_keys

-- Criando uma Coluna para o dado Criptografado
ALTER TABLE HumanResources.Employee
	ADD EncryptedNationalIDNumber varbinary(128)
GO
Select EncryptedNationalIDNumber, * From HumanResources.Employee

-- Abre a chave simetrica com a qual os dados será criptografado
OPEN SYMMETRIC KEY SYM_KEY_01
	DECRYPTION BY CERTIFICATE HumanResources_Cert
	
-- Chaves abertas
Select * From sys.openkeys

-- Encriptografando...
UPDATE HumanResources.Employee
SET EncryptedNationalIDNumber = EncryptByKey(Key_GUID('SYM_Key_01'), NationalIDNumber);
GO
Select EncryptedNationalIDNumber, * From HumanResources.Employee

-- Lendo os dados Criptografados e Descriptografados
Select 
	NationalIDNumber
,	EncryptedNationalIDNumber
,	Descriptografado = CONVERT(nvarchar, DECRYPTBYKEY(EncryptedNationalIDNumber))
From HumanResources.Employee