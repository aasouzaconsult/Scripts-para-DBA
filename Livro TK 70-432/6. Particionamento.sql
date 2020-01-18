-- 1. Criando um Banco de Dados para ser particionado
CREATE DATABASE Particionamento
ON PRIMARY
	(	NAME = Primario_Data
	,	FILENAME = 'D:\Alex\SQL Server\Diretorio de Dados\Particionamento\primario.mdf'
	,	SIZE = 4MB)
,
FILEGROUP FG1
	(	NAME = FG1_Data
	,	FILENAME = 'D:\Alex\SQL Server\Diretorio de Dados\Particionamento\FG1.ndf'
	,	SIZE = 2MB)
	,
FILEGROUP FG2
	(	NAME = FG2_Data
	,	FILENAME = 'D:\Alex\SQL Server\Diretorio de Dados\Particionamento\FG2.ndf'
	,	SIZE = 2MB)
	,
FILEGROUP FG3
	(	NAME = FG3_Data
	,	FILENAME = 'D:\Alex\SQL Server\Diretorio de Dados\Particionamento\FG3.ndf'
	,	SIZE = 2MB)
	,
FILEGROUP FG4
	(	NAME = FG4_Data
	,	FILENAME = 'D:\Alex\SQL Server\Diretorio de Dados\Particionamento\FG4.ndf'
	,	SIZE = 2MB)
	,
FILEGROUP FG5
	(	NAME = FG5_Data
	,	FILENAME = 'D:\Alex\SQL Server\Diretorio de Dados\Particionamento\FG5.ndf'
	,	SIZE = 2MB)
	,
FILEGROUP FG6
	(	NAME = FG6_Data
	,	FILENAME = 'D:\Alex\SQL Server\Diretorio de Dados\Particionamento\FG6.ndf'
	,	SIZE = 2MB)
	,
FILEGROUP FG7
	(	NAME = FG7_Data
	,	FILENAME = 'D:\Alex\SQL Server\Diretorio de Dados\Particionamento\FG7.ndf'
	,	SIZE = 2MB)
	,
FILEGROUP FG8
	(	NAME = FG8_Data
	,	FILENAME = 'D:\Alex\SQL Server\Diretorio de Dados\Particionamento\FG8.ndf'
	,	SIZE = 2MB)
	,
FILEGROUP FG9
	(	NAME = FG9_Data
	,	FILENAME = 'D:\Alex\SQL Server\Diretorio de Dados\Particionamento\FG9.ndf'
	,	SIZE = 2MB)
	,
FILEGROUP FG10
	(	NAME = FG10_Data
	,	FILENAME = 'D:\Alex\SQL Server\Diretorio de Dados\Particionamento\FG10.ndf'
	,	SIZE = 2MB)
	,
FILEGROUP FG11
	(	NAME = FG11_Data
	,	FILENAME = 'D:\Alex\SQL Server\Diretorio de Dados\Particionamento\FG11.ndf'
	,	SIZE = 2MB)
	,
FILEGROUP FG12
	(	NAME = FG12_Data
	,	FILENAME = 'D:\Alex\SQL Server\Diretorio de Dados\Particionamento\FG12.ndf'
	,	SIZE = 2MB)
	,
FILEGROUP FG13
	(	NAME = FG13_Data
	,	FILENAME = 'D:\Alex\SQL Server\Diretorio de Dados\Particionamento\FG13.ndf'
	,	SIZE = 2MB)
	
LOG ON
	(	NAME = Part_Log
	,	FILENAME = 'D:\Alex\SQL Server\Diretorio de Dados\Particionamento\Log.ldf'
	,	SIZE = 2MB)
	
Use Particionamento
GO
-- Criando a Função de Partição
CREATE PARTITION FUNCTION partfunc (datetime) AS
RANGE RIGHT FOR VALUES ('20050101', '20050201', '20050301', '20050401', '20050501', '20050601'
, '20050701', '20050801', '20050901', '20051001', '20051101', '20051201')

SELECT * FROM sys.partition_range_values

--Criando um Schema de Partição
CREATE PARTITION SCHEME partscheme AS
PARTITION partfunc TO
([FG1], [FG2], [FG3], [FG4], [FG5], [FG6], [FG7], [FG8], [FG9], [FG10], [FG11], [FG12], [FG13]);
GO

SELECT * FROM sys.partition_schemes;
GO

-- Criando uma Tabela utilizando o schema de partição
CREATE TABLE dbo.Orders (
	OrderID	int identity(1,1)
,	OrderDate datetime not null
,	OrderAmount money not null
CONSTRAINT pk_orders PRIMARY KEY CLUSTERED (OrderDate, OrderID))
-- AQUI 
ON partscheme(OrderDate)
GO

-- Populando a tabela

INSERT INTO dbo.Orders VALUES ('20050104', 1)
,	('20050204', 2)
,	('20050304', 3)
,	('20050512', 4)
,	('20050328', 5)
,	('20050406', 6)
,	('20050902', 7)
,	('20051030', 8)

SELECT * FROM dbo.Orders

-- Vendo os dados Particionados
SELECT * FROM sys.partitions WHERE object_id = object_id('dbo.Orders')

--SET NOCOUNT ON
--DECLARE @month	int
--,		@day	int

--SET		@month = 1
--SET		@day = 1

--WHILE	@month <=12
--BEGIN
--	WHILE @day <= 28
--	BEGIN
--		INSERT dbo.Orders (OrderDate, OrderAmount)
--		SELECT CAST(@month as varchar(2)) + '/' + CAST(@day as varchar(2)) + '/2005', @day * 20
--		SET @day = @day + 1
--	END
	
--	SET @day = 1
--	SET @month = @month + 1
--END
--GO
