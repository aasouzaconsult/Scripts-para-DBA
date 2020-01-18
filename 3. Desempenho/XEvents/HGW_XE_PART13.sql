--Criação da sessão de monitoração
CREATE EVENT SESSION [XE_MEM_MONITOR] ON SERVER 
ADD EVENT sqlserver.server_memory_change(
    ACTION(sqlserver.database_name,sqlserver.sql_text)),
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(sqlserver.database_name,sqlserver.sql_text)
    WHERE ([sqlserver].[database_id]=(5))) 
ADD TARGET package0.ring_buffer
GO

--Criação da massa de dados
USE AdventureWorks2012
GO
CREATE TABLE PESSOA
(Codigo INT, Nome VARCHAR(100), Sobrenome VARCHAR(100),
Email VARCHAR(100))
GO
INSERT PESSOA
SELECT 
	BusinessEntityID,
	FirstName,
	LastName,
	LastName+'@email.com.br'
FROM
	Person.Person
GO 1000


--Limpar buffer de memória
DBCC DROPCLEANBUFFERS
GO

--Comando T-SQL que exigirá mais alocação de memória
UPDATE PESSOA SET Nome = 'Ze'
WHERE Nome = 'KIM' OR Nome = 'Edward'

--Leitura do XML
SELECT 
Name,
CAST(target_data AS XML) AS XMLData
FROM sys.dm_xe_sessions AS s 
JOIN sys.dm_xe_session_targets AS t 
    ON t.event_session_address = s.address