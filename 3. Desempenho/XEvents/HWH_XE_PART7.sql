-- Criar o banco de dados HGW_XE
CREATE DATABASE HGW_XE 
GO 
USE HGW_XE 
GO 
-- Criar a TabelaTeste 
CREATE TABLE dbo.TabelaTeste (
	Col1 int IDENTITY(1,1), 
	Col2 varchar(8000)
) 
GO 
-- Inserir dados na tabela
INSERT INTO dbo.TabelaTeste (Col2) 
	SELECT REPLICATE('A','8000') 
GO 200 

--Criar a sessão de monitoração
CREATE EVENT SESSION [XE_SORTWARNING] ON SERVER 
ADD EVENT sqlserver.sort_warning(
    ACTION(sqlserver.database_name,sqlserver.sql_text,
	sqlserver.username)) 
ADD TARGET package0.ring_buffer
GO

-- Gerar Sort Warning
DECLARE @T1 TABLE (
	Col1 int, 
	Col2 varchar(8000)
) 
INSERT INTO @T1 SELECT * FROM dbo.TabelaTeste 
SELECT Col2, COUNT(*) FROM @T1 GROUP BY Col2