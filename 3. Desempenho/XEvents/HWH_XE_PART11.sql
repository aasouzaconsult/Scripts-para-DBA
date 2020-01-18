CREATE DATABASE DBTeste
GO
CREATE EVENT SESSION [XE_DB_RESIZE] ON SERVER 
ADD EVENT sqlserver.database_file_size_change(
    ACTION(sqlserver.database_name,sqlserver.sql_text)
    WHERE ([database_id]=(6))) 
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=4096 KB,
EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,
MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO
USE DBTeste
GO
CREATE TABLE Pessoa
(Codigo INT IDENTITY(1,1),
Nome VARCHAR(400),Email VARCHAR(500))
GO

INSERT INTO Pessoa
SELECT FirstName,
LastName +'@email.com.br'
FROM AdventureWorks2012.Person.Person
GO 100