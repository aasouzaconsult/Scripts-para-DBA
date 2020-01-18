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


-- http://msdn.microsoft.com/pt-br/library/ms176029.aspx
/* O banco de dados do sistema tempdb é um recurso global disponível a todos os 
usuários conectados a uma instância do SQL Server. O banco de dados tempdb é 
utilizado para armazenar os seguintes objetos: objetos do usuário, objetos 
internos e armazenamentos de versão.
Você pode utilizar a exibição de gerenciamento dinâmico sys.dm_db_file_space_usage 
para monitorar o espaço em disco utilizado pelos objetos de usuário, objetos 
internos e armazenamentos de versão nos arquivos tempdb. Além disso, para monitorar 
a atividade de alocação ou desalocação de página em tempdb no nível da sessão ou 
tarefa, você pode utilizar as exibições de gerenciamento 
dinâmico sys.dm_db_session_space_usage e sys.dm_db_task_space_usage. 
Essas exibições podem ser utilizadas para identificar consultas grandes, 
tabelas temporárias ou variáveis de tabela que estão utilizando muito espaço em 
disco de tempdb. */

select * from sys.dm_db_file_space_usage
select * from sys.dm_db_session_space_usage
select * from sys.dm_db_task_space_usage

-- Determinando a quantidade de espaço livre em tempdb
SELECT SUM(unallocated_extent_page_count) AS [free pages], 
(SUM(unallocated_extent_page_count)*1.0/128) AS [free space in MB]
FROM sys.dm_db_file_space_usage;

-- Determinando o volume de espaço usado pelo armazenamento de versão
SELECT SUM(version_store_reserved_page_count) AS [version store pages used],
(SUM(version_store_reserved_page_count)*1.0/128) AS [version store space in MB]
FROM sys.dm_db_file_space_usage;

-- Determinando a transação mais longa em execução
SELECT transaction_id
FROM sys.dm_tran_active_snapshot_database_transactions 
ORDER BY elapsed_time_seconds DESC;

-- Determinando o volume de espaço usado por objetos internos
SELECT SUM(internal_object_reserved_page_count) AS [internal object pages used],
(SUM(internal_object_reserved_page_count)*1.0/128) AS [internal object space in MB]
FROM sys.dm_db_file_space_usage;

-- Determinando o volume de espaço usado por objetos do usuário
SELECT SUM(user_object_reserved_page_count) AS [user object pages used],
(SUM(user_object_reserved_page_count)*1.0/128) AS [user object space in MB]
FROM sys.dm_db_file_space_usage;