----Criando uma sessão para erros 
CREATE EVENT SESSION
   XE_QUERYERRORS
ON SERVER
ADD EVENT sqlserver.error_reported
(
    ACTION (sqlserver.sql_text, sqlserver.tsql_stack, 
	sqlserver.database_id, sqlserver.username)
    WHERE ([severity]> 10)
)
ADD TARGET package0.asynchronous_file_target
(set filename = 'C:\XE\QueryErrors.xel' ,
    metadatafile = 'C:\XE\QueryErrors.xem',
    max_file_size = 5,
    max_rollover_files = 5)
WITH (MAX_DISPATCH_LATENCY = 5SECONDS)
GO
 
-- Iniciando a sessão
ALTER EVENT SESSION QueryErrors
    ON SERVER STATE = START
GO

--Forçando um erro
USE AdventureWorks2012;
GO
SELECT * FROM Person.Person WHERE ModifiedDate='20aaa';
GO