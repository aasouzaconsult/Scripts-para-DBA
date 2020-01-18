/*************************************
 * DBCC = DATABASE CONSISTENCY CHECK *
 *************************************/

SP_SPACEUSED -- Verifica uso de espaço do Banco
SP_SPACEUSED TbRegistros -- Verifica uso de espaço de tabela

--Returns syntax information for the specified DBCC command.
DBCC HELP ('?');

-------------------------
-- Paginas corrompidas --
-------------------------
SELECT * FROM msdb..Suspect_pages

-- Checar integridade do banco de dados
DBCC CHECKDB ('BDTeste')

-- Verificar se existem páginas suspeitas (pages suspect)
Select	database_id
,		file_id
,		page_id
,		event_type
,		error_count
,		last_update_date
From	msdb.dbo.Suspect_Pages

/***********
 * Reparar *
 ***********/
-- Situações:
-- - Banco de dados em Status: SUSPECT

Select	[Banco(ID)] = UPPER(name + ' (' + convert(varchar, database_id) + ')')
,		[Status] = state_desc
,		[Modo] = user_access_desc
,		[Recovery Model] = recovery_model_desc + ' (' + convert(varchar, recovery_model) + ')'
,		[Page Verify] = page_verify_option_desc + ' (' + convert(varchar, page_verify_option) + ')'
From	sys.databases -- Consultar Status ( http://msdn.microsoft.com/pt-br/library/ms178534.aspx )
 
-- Desabilitar login (se necessário)
ALTER LOGIN [LoginTesteDB] DISABLE

ALTER DATABASE TesteDB SET EMERGENCY

-- Checar integridade do banco de dados
DBCC CHECKDB ('TesteDB') -- http://msdn.microsoft.com/pt-br/library/ms176064.aspx
--EXEC SP_RESETSTATUS 'TesteDB'; -- http://msdn.microsoft.com/pt-br/library/ms188424.aspx

-- Se contiver erros
ALTER DATABASE TesteDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE
go
DBCC CHECKDB (TesteDB, REPAIR_ALLOW_DATA_LOSS) WITH NO_INFOMSGS, ALL_ERRORMSGS --REPAIR_ALLOW_DATA_LOSS | REPAIR_FAST | REPAIR_REBUILD*
go

ALTER DATABASE TesteDB SET read_write
ALTER DATABASE TesteDB SET multi_user
go

-- habilitar login (se necessário)
ALTER LOGIN [loginteste] ENABLE

-- Se aplicave;
RESTORE DATABASE [TesteDB] 
FROM  DISK = N'D:\Bancos de Dados\TesteDB.bak' 
WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 10

-- Checar integridade de indíces (Reduz páginas alocadas)
DBCC DBREINDEX ('BDTeste.dbo.TbRegistros')
/* Após a execução do DBCC DBREINDEX é recomendado que seja executado o comando 
UPDATE STATISTICS, para que as estatísticas utilizadas pelo otimizador, possam 
trabalhar com a nova alocação dos índices.*/

-- DBCC INDEXDEFRAG : Este comando é bastante similar ao anterior, porém foi 
--desenvolvido para que pudesse ser executado mesmo com os usuários utilizando 
--a base de dados (Não reduz páginas alocadas)
DBCC INDEXDEFRAG (BDTeste, TbRegistros)

-- DBCC UPDATEUSAGE : Esta opção de DBCC tem por objetivo reportar e corrigir 
--imprecisões na tabela sysindexes, os quais podem resultar em informações 
--incorretas sobre o espaço utilizado por uma tabela ou mesmo pela base de 
--dados quando da execução da sp_spaceused.
DBCC UPDATEUSAGE ('BDteste') 

-- Drops a damaged database. 
--DBCC DBREPAIR

-- Checks the consistency of disk space allocation structures for a specified database.
DBCC CHECKALLOC; -- Check the current database. 
DBCC CHECKALLOC ('AdventureWorks'); -- Check the AdventureWorks database.

-- Checks the integrity of all the pages and structures that make up the table 
--or indexed view.
DBCC CHECKTABLE ('dbo.Tbregistros');

-- Checks the allocation and structural integrity of all tables and indexed 
--views in the specified filegroup of the current database.
DBCC CHECKFILEGROUP;
-- Checking the AdventureWorks PRIMARY filegroup without nonclustered indexes
DBCC CHECKFILEGROUP (1, NOINDEX);

-- Checks the current identity value for the specified table and, if it is needed, 
--changes the identity value. You can also use DBCC CHECKIDENT to manually set a 
--new seed value for the identity column.
DBCC CHECKIDENT ('Tbregistros');

-- Checks for catalog consistency within the specified database. The database must 
--be online. 
DBCC CHECKCATALOG; -- Check the current database.
DBCC CHECKCATALOG ('AdventureWorks'); -- Check the AdventureWorks database.

-- Checking all enabled and disabled constraints on all tables
DBCC CHECKCONSTRAINTS WITH ALL_CONSTRAINTS;

-- Unloads the specified extended stored procedure DLL from memory.
DBCC xp_sample (FREE);

-- Removes all clean buffers from the buffer pool.
DBCC DROPCLEANBUFFERS

-- Displays information in a table format about the procedure cache.
DBCC PROCCACHE
-- Removes all elements from the procedure cache.
DBCC FREEPROCCACHE 

-- Flushes the distributed query connection cache used by distributed queries 
--against an instance of Microsoft SQL Server.
DBCC FREESESSIONCACHE

-- Releases all unused cache entries from all caches. The SQL Server 2005 Database 
--Engine proactively cleans up unused cache entries in the background to make memory 
--available for current entries. However, you can use this command to manually remove 
--unused entries from all caches. 
DBCC FREESYSTEMCACHE 

-- Displays the last statement sent from a client to an instance of Microsoft SQL 
--Server 2005.
DBCC INPUTBUFFER (52);
-- http://technet.microsoft.com/en-us/library/ms187730.aspx

-- Returns the current output buffer in hexadecimal and ASCII format for the specified 
--session_id.
select @@spid
DBCC OUTPUTBUFFER (66);

-- Displays information about the oldest active transaction and the oldest distributed 
--and nondistributed replicated transactions, if any, within the specified database. 
--Results are displayed only if there is an active transaction or if the database 
--contains replication information. An informational message is displayed if 
--there are no active transactions. 
DBCC OPENTRAN;
-- (http://technet.microsoft.com/en-us/library/ms182792.aspx)

-- Marks a table to be pinned. This means the SQL Server Database Engine does not flush 
--the pages for the table from memory.
DBCC PINTABLE
-- Marks a table as unpinned. After a table is marked as unpinned, the table pages in the 
--buffer cache can be flushed.
DBCC UNPINTABLE 

-- Displays the current distribution statistics for the specified target on the 
--specified table.
USE AdventureWorks;
GO
DBCC SHOW_STATISTICS ('Person.Address', AK_Address_rowguid);
GO
DBCC SHOW_STATISTICS ('Person.Address', AK_Address_rowguid) WITH HISTOGRAM;

-- Displays fragmentation information for the data and indexes of the specified 
--table or view.
DBCC SHOWCONTIG ('HumanResources.Employee');

-- Shrinks the size of the data and log files in the specified database.
DBCC SHRINKDATABASE (UserDB, 10);
DBCC SHRINKDATABASE (AdventureWorks, TRUNCATEONLY);

-- No Shrink deve usar o Logical Name, no exemplo abaixo é Exemplo_Log, vejo em:
-- Clicando no banco > propriety > files
DBCC SHRINKFILE (N'Exemplo_Log' , 0, TRUNCATEONLY)
-- Shrink direto na Base
DBCC SHRINKFILE (N'Exemplo' , 0, TRUNCATEONLY)

-- Provides transaction log space usage statistics for all databases. It can also 
--be used to reset wait and latch statistics.
DBCC SQLPERF(LOGSPACE);
-- The following example resets the wait statistics for the instance of SQL Server.
--DBCC SQLPERF('sys.dm_os_wait_stats',CLEAR);

-- Returns the SET options active (set) for the current connection. 
DBCC USEROPTIONS;

-- Displays the status of trace flags.
DBCC TRACESTATUS(-1); -- All Globally
DBCC TRACESTATUS (2528, 3205);
DBCC TRACESTATUS (3205, -1);

-- Disables the specified trace flags.
DBCC TRACEOFF (3205);
DBCC TRACEOFF (3205, -1); -- Globalmente

-- Enables the specified trace flags.
DBCC TRACEON (3205);
DBCC TRACEON (3205, -1); -- Globalmente

-- In Microsoft SQL Server 2005, DBCC CONCURRENCYVIOLATION is maintained for backward compatibility. DBCC CONCURRENCYVIOLATION runs but returns no data. 
DBCC CONCURRENCYVIOLATION