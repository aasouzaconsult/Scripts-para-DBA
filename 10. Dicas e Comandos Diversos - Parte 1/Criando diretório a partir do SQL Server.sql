--
-- Criando diretório a partir do SQL Server
--
USE Master;
GO 
SET NOCOUNT ON
 
-- Declaracao das variáveis
DECLARE @DBName sysname
DECLARE @DataPath nvarchar(500)
DECLARE @LogPath nvarchar(500)
DECLARE @DirTree TABLE (subdirectory nvarchar(255), depth INT)
 
-- Inicializacao das variaveis
SET @DBName = 'BancoTeste'
SET @DataPath = 'C:\Diretorio1\' + @DBName
SET @LogPath = 'C:\Diretorio2\' + @DBName
 
-- @DataPath values
INSERT INTO @DirTree(subdirectory, depth)
EXEC master.sys.xp_dirtree @DataPath
 
-- Cria o diretorio contido na variavel @DataPath
IF NOT EXISTS (SELECT 1 FROM @DirTree WHERE subdirectory = @DBName)
EXEC master.dbo.xp_create_subdir @DataPath
 
-- Remove todos os registros de @DirTree
DELETE FROM @DirTree
 
-- @LogPath values
INSERT INTO @DirTree(subdirectory, depth)
EXEC master.sys.xp_dirtree @LogPath
 
-- Cria o diretorio contido na variavel @LogPath
IF NOT EXISTS (SELECT 1 FROM @DirTree WHERE subdirectory = @DBName)
EXEC master.dbo.xp_create_subdir @LogPath
SET NOCOUNT OFF
GO


  
 
-- Sobre as duas stored procedures extendidas:
 
-- master.sys.xp_dirtree - Retorna todos os diretórios existentes dentro do diretorio passado como parâmetro.
 
-- master.sys.xp_create_subdir - Usada para criar o diretório no servidor local ou compartilhamento na rede.
