Windows File System Directory Creation Script 
Platform = SQL Server 2005 
USE Master;
GO 
SET NOCOUNT ON

-- 1 - Variable declaration
DECLARE @DBName sysname
DECLARE @DataPath nvarchar(500)
DECLARE @LogPath nvarchar(500)
DECLARE @DirTree TABLE (subdirectory nvarchar(255), depth INT)

-- 2 - Initialize variables
SET @DBName = 'Foo'
SET @DataPath = 'C:\zTest1\' + @DBName
SET @LogPath = 'C:\zTest2\' + @DBName

-- 3 - @DataPath values
INSERT INTO @DirTree(subdirectory, depth)
EXEC master.sys.xp_dirtree @DataPath

-- 4 - Create the @DataPath directory
IF NOT EXISTS (SELECT 1 FROM @DirTree WHERE subdirectory = @DBName)
EXEC master.dbo.xp_create_subdir @DataPath

-- 5 - Remove all records from @DirTree
DELETE FROM @DirTree

-- 6 - @LogPath values
INSERT INTO @DirTree(subdirectory, depth)
EXEC master.sys.xp_dirtree @LogPath

-- 7 - Create the @LogPath directory
IF NOT EXISTS (SELECT 1 FROM @DirTree WHERE subdirectory = @DBName)
EXEC master.dbo.xp_create_subdir @LogPath

SET NOCOUNT OFF

GO
 
