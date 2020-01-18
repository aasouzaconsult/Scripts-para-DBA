/* Situação  : Tenho 2 Bancos de Dados de 2 Sistemas distintos (2 Fornecedores de Solução)
   Problema  : Um dos bancos de dados (BD do Fornecedor B) precisam acessar determinados dados no outro banco de dados (BD do Fornecedor A).
   Solução   : Criamos uma Stored Procedure no BD do Fornecedor B pegando dados que necessitam no BD do Fornecedor A
   Observação: O usuário/login do Fornecedor B não tem acesso ao Banco de Dados do Fornecedor A
   
   Como podemos fazer isso?
*/

/***********************
 * Montagem do Cenário *
 ***********************/
-------------------------------------------
-- Criando o Banco de dados Fornecedor A --
-------------------------------------------
CREATE DATABASE DA;
USE DA;
-- Criando tabela de exemplo
CREATE TABLE TA (id int, nm varchar(15))

-- Inserindo algumas coisas
INSERT INTO TA VALUES (1, 'AAAA'), (2, 'BBBB')

-- Selecionando as informações
SELECT * FROM TA

------------------------------------
-- Criando o Login / Usuário (LB) --
------------------------------------
-- O Usuário LA é Dono (db_owner) do Banco DA e SYSADMIN
USE [master]
GO
CREATE LOGIN [LA] WITH PASSWORD=N'', DEFAULT_DATABASE=[DB], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
EXEC master..sp_addsrvrolemember @loginame = N'LA', @rolename = N'sysadmin'
GO
USE [DA]
GO
CREATE USER [LA] FOR LOGIN [LA]
GO
USE [DA]
GO
EXEC sp_addrolemember N'db_owner', N'LA'
GO


------------------------------------
-- Banco de dados do fornecedor B --
------------------------------------
CREATE DATABASE DB;
USE DB;

-- Criando tabela de exemplo
CREATE TABLE TB (id int, nm varchar(15))

-- Inserindo algumas coisas
INSERT INTO TB VALUES (1, 'CCCC'), (2, 'DDDD')

-- Selecionando as informações
SELECT * FROM TB

------------------------------------
-- Criando o Login / Usuário (LB) --
------------------------------------
-- O Usuário LB é Dono (db-owner) do Banco DB
USE [master]
GO
CREATE LOGIN [LB] WITH PASSWORD=N'', DEFAULT_DATABASE=[DB], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
USE [DB]
GO
CREATE USER [LB] FOR LOGIN [LB]
GO
USE [DB]
GO
EXEC sp_addrolemember N'db_owner', N'LB'
GO

-- *-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Criaremos uma Stored Procudure no Banco de Dados do Fornecedor B (DB) para acessar dados do Banco de Dados do Fornecedor A (DA)
-- Só lembrando que o usuário do Fornecedor B (LB) não tem acesso ao Banco de Dados do Fornecedor A (DA)
-- *-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

USE [DB]
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_frnA]
AS
BEGIN
  	SELECT * FROM DA.dbo.[TA]
END

-- Onde TA - Tabela do Banco de Dados do Fornecedor A


-- ################################
-- # FAZER LOGIN COM O USUÁRIO LB #
-- ################################

-- Vamos fazer o login com LB (só lembrando: O Usuário LB é Dono (db-owner) do Banco DB e não tem acesso ao DA)
-- Onde DB - Banco de Dados do Fornecedor B
-- Onde DA - Banco de Dados do Fornecedor A

-- LB = Login do usuário do Banco de Dados: DB (este login não tem acesso ao DA)
-- LA = Login do usuário do Banco de Dados: DA

-- Agora vamos tentar executar a procedure sp_frnA
exec sp_frnA

-- Irá aparecer a mensagem:
Msg 916, Level 14, State 1, Procedure sp_frnA, Line 4
The server principal "LB" is not able to access the database "DA" under the current security context.

-- Basicamente dizendo que o LB (login do fornecedor B) não tem acesso ao DA (Banco de dados do Fornecedor A)


-- Vamos alterar a procedure para executar com o Login: LA (por dentro da propria procedure):
-- ################################
-- # FAZER LOGIN COM O USUÁRIO LA #
-- ################################

ALTER PROCEDURE [dbo].[sp_frnA]
AS
BEGIN
    EXECUTE AS LOGIN = 'LA';

  	SELECT * FROM DA.dbo.[TA]
END


-- ################################
-- # FAZER LOGIN COM O USUÁRIO LB #
-- ################################

-- Vamos executar agora:
exec sp_frnA

-- Apresentou:
Msg 15406, Level 16, State 1, Procedure sp_frnA, Line 4
Cannot execute as the server principal because the principal "LA" does not exist, this type of principal cannot be impersonated, or you do not have permission.

-- Vamos fazer a seguinte alteração para que o usuário LB representasse o LA
-- Cuidado com este tipo de acesso, mas é uma solução dependendo do caso!
-- ################################
-- # FAZER LOGIN COM O USUÁRIO LA #
-- ################################

USE master
GRANT IMPERSONATE ON LOGIN:: LA TO LB;


-- ################################
-- # FAZER LOGIN COM O USUÁRIO LB #
-- ################################

-- Vamos executar novamente:

exec sp_frnA

-- Apareceu!!!


Espero ter ajudado!

-- Maiores informações de IMPERSONATE
http://msdn.microsoft.com/pt-br/library/ms181362.aspx