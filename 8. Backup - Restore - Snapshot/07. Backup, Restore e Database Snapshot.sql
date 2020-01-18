-- Alterando o Modo de Recuperação
ALTER DATABASE DB_TK432
SET RECOVERY FULL -- Full, Bulk_Logged, Simple
GO

-- Tipos de Backup
-- FULL (Cheio)
-- DIFFERENTIAL (Diferencial)
-- TRAN LOG (Log de Transações)

-- BACKUP
-- Backup do Banco de Dados ADVENTUREWORKS (FULL)
BACKUP DATABASE AdventureWorks TO DISK = 'D:\Alex\SQL Server\Backups\bkp_AdventureWorks.bak'
	WITH NOFORMAT -- Especifica que a operação de backup preserva o cabeçalho da mídia e os conjuntos de backup existentes nos volumes de mídia usados para esta operação de backup. Esse é o comportamento padrão.
,	COMPRESSION -- Comprime o Backup
,	INIT -- Controla se a operação de backup anexa ou substitui os conjuntos de backup existentes na mídia de backup. O padrão é anexar ao backup mais recente definido na mídia (NOINIT).
,	NAME = 'AdventureWorks' -- Nome do conjunto de backup
,	SKIP -- Desabilita a verificação de validade e nome do conjunto de backup que normalmente é executada pela instrução BACKUP para impedir a substituição de conjuntos de backup.
,	NOREWIND -- Especifica que o SQL Server mantém a fita aberta após a operação de backup.
,	NOUNLOAD -- Especifica que depois da operação BACKUP a fita permanecerá carregada na unidade de fita.
,	STATS = 10 -- Porcentagem concluída
GO
-- Backup do Banco de Dados ADVENTUREWORKS (DIFERENCIAL)
BACKUP DATABASE AdventureWorks TO DISK = 'D:\Alex\SQL Server\Backups\bkp_AdventuteWorks_dif.bak'
WITH DIFFERENTIAL, NOFORMAT, INIT, Name = 'AdventureWorks - Differential', SKIP, NOREWIND, NOUNLOAD, STATS = 25
GO

-- Backup do Banco de Dados ADVENTUREWORKS (LOG)
BACKUP LOG AdventureWorks TO  DISK = 'D:\Alex\SQL Server\Backups\bkp_AdventuteWorks_Log.bak' 
WITH NOFORMAT, INIT, NAME = N'AdventureWorks -Log',	SKIP, NOREWIND,	NOUNLOAD, STATS = 10
GO

-- RESTORE
RESTORE DATABASE AdventureWorks FROM DISK = 'D:\Alex\SQL Server\Backups\bkp_AdventureWorks.bak'
WITH REPLACE
,	 NORECOVERY -- Deixa aberto para recuperar um proximo backup
,	 STATS=10

RESTORE LOG AdventureWorks FROM  DISK = 'D:\Alex\SQL Server\Backups\bkp_AdventuteWorks_Log.bak'
WITH RECOVERY
,	 STATS = 10 

/***********************************************
 * RESTAURANDO a Base de Dados MASTER e a MSDB *
 ***********************************************/
-- ****** 
-- MASTER
-- ******
-- 1. Passo - Entrar no Prompt de Comando

-- 2. Passo - Parar o Serviço do SQL Server (1. Prompt de Comando)
-- C:\> NET STOP MSSQLSERVER

-- 3. Restartar o SQL Server com Single Mode (2. Prompt de Comando)
-- C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Binn> SQLSERVR.EXE -m

-- 4. Entra no SQLCMD (3. Prompt de Comando)
-- C:\> SQLCMD -SLOCALHOST -E

-- 5. Restaurar o backup do Banco de Dados Master
-- 1> RESTORE DATABASE MASTER FROM DISK = 'C:\BACKUP_MASTER.BAK' WITH REPLACE
-- 2> GO

-- 6. Restartar o SQL Server (Normal - 1. Prompt de Comando)
-- C:\> NET START MSSQLSERVER
 
-- ****
-- MSDB
-- ****
-- 1. No SQL Server Management Studio, com o serviço do SQL Server Agent Parado
-- RESTORE DATABASE MSDB FROM DISK = 'C:\BACKUP_MSDB.BAK' 

/*********************
 * DATABASE SNAPSHOT *
 *********************/
 --Criando um Database Snapshot
CREATE DATABASE DB_TK432_Snapshot
ON
(	NAME = 'TK432_Data' -- Logical Name
,	FILENAME = 'D:\x_TempSQL\DB_TK432_Snapshot.ds'),
(	NAME = 'TK432_Data2' -- Logical Name
,	FILENAME = 'D:\x_TempSQL\DB_TK432_2_Snapshot.ds')
AS SNAPSHOT OF DB_TK432; -- Banco de Dados Origem

-- Usando o Database Snapshot
Use DB_TK432;

-- Deletando um Database Snapshot
DROP DATABASE DB_TK432_Snapshot