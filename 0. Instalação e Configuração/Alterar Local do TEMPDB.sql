-- http://msdn.microsoft.com/pt-br/library/ms345408.aspx (Movendo bancos de dados do sistema)

-- Mostra nome lógico e caminho atual do tempdb
SELECT name, physical_name AS CurrentLocation
FROM sys.master_files
WHERE database_id = DB_ID(N'tempdb');
GO

-- Procedimento de alteração
USE master;
GO
ALTER DATABASE tempdb 
MODIFY FILE (NAME = tempdev, FILENAME = 'D:\Data\tempdb.mdf');
GO
ALTER DATABASE tempdb 
MODIFY FILE (NAME = templog, FILENAME = 'D:\Data\templog.ldf');
GO

-- REINICIAR A INSTANCIA

-- Mostra nome lógico e caminho atual do tempdb
SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'tempdb');