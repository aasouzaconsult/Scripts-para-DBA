CREATE DATABASE WEBCAST
GO

--Criando uma tabela que usa compressão de linha
CREATE TABLE TABELA1
 (COLUNA1 INT,
  COLUNA2 NVARCHAR(50))
WITH (DATA_COMPRESSION = ROW);
GO

--Criando uma tabela que usa compressão de página
CREATE TABLE TABELA2
 (COLUNA1 INT,
  COLUNA2 NVARCHAR(50))
WITH (DATA_COMPRESSION = PAGE);
GO

--Modificando uma tabela de para a compactação
ALTER TABLE TABELA1
 REBUILD WITH (DATA_COMPRESSION=PAGE);
GO

--Criando índice compactado
CREATE NONCLUSTERED INDEX IX_INDEX_1 ON TABELA(COLUNA2)
 WITH (DATA_COMPRESSION = ROW);
GO

--Modificando a compactação do índice
ALTER INDEX IX_INDEX_1 ON TABELA1
 REBUILD WITH(DATA_COMPRESSION=PAGE);
GO