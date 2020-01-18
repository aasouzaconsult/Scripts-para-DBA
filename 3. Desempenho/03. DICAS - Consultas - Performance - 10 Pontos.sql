/*	Por Fabiano Neves Amorim
	Performance de querys é sem dúvida uma das maiores causadoras de dor de cabeça em DBAs e afins(J), 
se vocês já leram algum post neste blog devem ter percebido que gosto muito deste assunto, trato 
diariamente com problemas deste tipo e tem alguns pontos que acho importantes de serem analisados quando 
falamos em análise de consultas, vou tentar explicar melhor abaixo.

Primeiro vou falar um pouco da empresa onde trabalho a, CNP-M, graças a Deus somos uma empresa certificada 
MPS.BR pois os processos que foram implantados nos ajudam a diminuir e MUITO possíveis problemas de 
performance que teríamos e que não deixamos chegar nos clientes pois param no processo de validação. 
Os pontos que vou mencionar abaixo servem como base para procurar possíveis problemas de performance, 
bom chega de conversa mole e vamos para a melhor parte(você já sabe, TSQL).

Todas as consultas abaixo foram executadas no banco AdventureWorks / SQL Server 2005. 

1. Sempre verificar o plano de execução de cada select existente no código SQL, e analisar o uso ou não 
uso dos índices de cada tabela pertencente a query.

2. Verificar o uso de Functions. Caso exista alguma function envolvida no SQL analise bem a consulta e 
verifique se é possível alterar a consulta para fazer um join com a própria tabela ou então até mesmo 
tabelas temporárias, vamos ver alguns exemplos para ficar mais fácil de entender o que estou querendo 
dizer. */

IF OBJECT_ID('VendaPorCliente') IS NOT NULL
	DROP FUNCTION dbo.VendaPorCliente
GO

CREATE FUNCTION dbo.VendaPorCliente(@CustomerID Int)
RETURNS Decimal(18,2)
AS
BEGIN
	DECLARE @Total Decimal(18,2)

	SELECT 
			@Total = SUM(OrderQty * UnitPrice)
	FROM	AdventureWorks.Sales.SalesOrderHeader a
	INNER JOIN AdventureWorks.Sales.SalesOrderDetail b ON a.SalesOrderID = b.SalesOrderID
	WHERE a.CustomerID = @CustomerID

  RETURN @Total
END

GO

/* Seleciona o total de venda por Customer
   Aqui temos um problema, pois para cada linha na tabela Customer o SQL Server irá
   executar a Function VendaPorCliente, ou seja se minha tabela Customer tiver
   50000 linhas o SQL irá acessar as tabelas de header e Detail 50000 vezes. */

SELECT 
		AccountNumber
,		dbo.VendaPorCliente(CustomerID) as Total
FROM AdventureWorks.Sales.Customer

/* Para resolver o problema da consuta acima poderiamos fazer o seguinte
   Criar uma nova function do tipo "multi-statement table-valued" */

IF OBJECT_ID('VendaTotalClientes') IS NOT NULL
	DROP FUNCTION dbo.VendaTotalClientes
GO

CREATE FUNCTION dbo.VendaTotalClientes()
	RETURNS @tb_result TABLE
	(	CustomerID Int
	,	Total      Decimal(18,2)
	,	PRIMARY KEY(CustomerID) )
AS
BEGIN
	INSERT INTO @tb_result 
	SELECT 
			a.CustomerID
	,		SUM(OrderQty * UnitPrice) Total
    FROM	AdventureWorks.Sales.SalesOrderHeader a
	INNER JOIN AdventureWorks.Sales.SalesOrderDetail b ON a.SalesOrderID = b.SalesOrderID
	GROUP BY a.CustomerID
	
	RETURN
END

GO

/*	Seleciona o total de venda por Customer
	Desta vez ao invés de acessar a function para cada linha da tabela Customer
	o SQL Server irá ler os dados das tabelas Header e Detail apenas 1 vez pois a function
	 irá retornar todos os dados em uma tabela. */

SELECT 
		AccountNumber
,		b.Total
FROM	AdventureWorks.Sales.Customer a
INNER JOIN dbo.VendaTotalClientes() b ON a.CustomerID = b.CustomerID

GO

/* Agora chegamos onde eu queria!, imagine que eu queria retornar o total de venda apenas do
Customer 'AW00000001', eu iriá escrever o seguinte select.
   O que acontece abaixo é que o SQL irá primeiro retornar todos os dados da function, ou seja,
todas as vendas por customer e depois aplicar o filtro de AccountNumber = 'AW00000001' */

SELECT 
		AccountNumber
,		b.Total
FROM	AdventureWorks.Sales.Customer a
INNER JOIN dbo.VendaTotalClientes() b ON a.CustomerID = b.CustomerID
WHERE a.AccountNumber = 'AW00000001'

GO

/* O ideal neste caso seria usar: */
SELECT 
		AccountNumber
,		dbo.VendaPorCliente(CustomerID) as Total
FROM	AdventureWorks.Sales.Customer
WHERE	AccountNumber = 'AW00000001'

GO

/*  Ou então simplesmente não utilizar a function e fazer o select direto nas tabelas */
SELECT 
		a.AccountNumber
,		SUM(OrderQty * UnitPrice) AS Total
FROM	AdventureWorks.Sales.Customer a
INNER JOIN  AdventureWorks.Sales.SalesOrderHeader b ON a.CustomerID = b.CustomerID
INNER JOIN AdventureWorks.Sales.SalesOrderDetail c ON b.SalesOrderID = c.SalesOrderID
WHERE a.AccountNumber = 'AW00000001'
GROUP BY a.AccountNumber

GO

/* Obs.: Atenção, o comando SET STATISTICS IO ON não leva em consideração as leituras efetuadas 
nas suas functions, o que certas vezes acaba gerando uma má interpretação do comando, portanto 
fique ligado nisso.

3. Sempre que possível substituir condições com OR por UNION ALL, por ex: */

SET NOCOUNT ON
GO

IF OBJECT_ID('Teste ') IS NOT NULL
	DROP TABLE Teste
GO

CREATE TABLE Teste 
(	ID			Int Identity(1,1)
,	CPF			Char(11)
,	Nome		VarChar(200)
,	Sobrenome	VarChar(200)
,	Endereco	VarChar(200)
,	Bairro		VarChar(200)
,	Cidade		VarChar(200))
GO

-- Inclui 1000 mil de linhas na tabela
INSERT INTO Teste(CPF, Nome, SobreNome, Endereco, Bairro, Cidade)
	VALUES('11111111111', NEWID(), 'Neves Amorim', NEWID(), NEWID(), NEWID())
GO 1000

CREATE CLUSTERED INDEX ix_ID ON Teste(ID)
GO

CREATE INDEX ix_Nome ON Teste(Nome)
GO

/* Seleciona todos os registros onde ID = 10 ou então o Nome inicia com 38.
   Esta consulta irá gerar um Scan na tabela pois o OR impede que o SQL use o ix_ID ou o ix_Nome. */

SELECT * FROM Teste
WHERE	ID = 10
OR		Nome Like '38%'
GO

/* A instrução acima deve ser trocada por a consulta abaixo que utiliza o UNION ALL */

SELECT Tab.* FROM 
	(	SELECT * FROM Teste
        WHERE ID = 10
		
		UNION ALL
	    
		SELECT * FROM Teste
        WHERE Nome Like '38%') AS Tab

/* Obs.: Sempre que possível utilize “UNION ALL” ao invés de “UNION” pois o “UNION” gera um 
distinct que geralmente gera um order by o que irá gerar um custo desnecessário comparado a 
concatenação do “UNION ALL”.*/

--6. Substituir o uso de CURSOR pelo comando WHILE + tabelas temporárias ou Variáveis do tipo table.

DECLARE @VendorID Int,
        @Name     VarChar(80)

DECLARE Cur_Vendor CURSOR FOR
 SELECT VendorID, Name
   FROM Purchasing.Vendor

OPEN Cur_Vendor

FETCH NEXT FROM Cur_Vendor
 INTO @VendorID, @Name

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @Name
    FETCH NEXT FROM Cur_Vendor
    INTO @VendorID, @Name
END

CLOSE Cur_Vendor
DEALLOCATE Cur_Vendor
GO

DECLARE @ROWID Int,
        @Name  VarChar(80)

SET @ROWID = 0;
 
SELECT TOP 1
       @ROWID = VendorID,
       @Name  = Name     
FROM Purchasing.Vendor
WHERE VendorID > @ROWID
ORDER BY VendorID

WHILE @@ROWCOUNT > 0
BEGIN
  PRINT @Name

  SELECT TOP 1
         @ROWID = VendorID,
         @Name  = Name     
  FROM Purchasing.Vendor
  WHERE VendorID > @ROWID
  ORDER BY VendorID
END
GO

-- 7. Verificar se as variáveis no WHERE são do mesmo DataType que a coluna da tabela.

DECLARE @TMP TABLE(Nome VarChar(80) PRIMARY KEY)
DECLARE @Nome NVarChar(80)
SET @Nome = 'Teste'

-- Gera FULL SCAN
SELECT * FROM @TMP
WHERE Nome = @Nome
GO

DECLARE @TMP TABLE(Nome VarChar(80) PRIMARY KEY)
DECLARE @Nome VarChar(80)
SET @Nome = 'Teste'

-- Gera SEEK
SELECT * FROM @TMP
WHERE Nome = @Nome

/* 8. Verificar se existe uso de variáveis do tipo Table para grande volume de dados, pois isso 
pode causar problema de performance já que variáveis do tipo table não usam proveito de paralelismo 
e não criam estatísticas com os dados da tabela.*/

/* 9. Verificar se é possível usar o conceito de Hash Index usando o CheckSum para gerar o número HASH, 
Caso existam colunas com valores muito grandes as vezes compensa usar o CheckSum para gerar o Hash e 
depois indexar a coluna hash. */

-- Create a checksum index.
SET ARITHABORT ON;
USE AdventureWorks;
GO

ALTER TABLE Production.Product
ADD cs_Pname AS CHECKSUM(Name);
GO

CREATE INDEX Pname_index ON Production.Product (cs_Pname);
GO

/*Use the index in a SELECT query. Add a second search
condition to catch stray cases where checksums match,
but the values are not the same.*/

SELECT * FROM Production.Product
WHERE CHECKSUM(N'Bearing Ball') = cs_Pname
AND Name = N'Bearing Ball';
GO

-- 10. Evite usar a clausula IN.
IF OBJECT_ID('tempdb.dbo.#TMP') IS NOT NULL
BEGIN
  DROP TABLE #TMP
END

CREATE TABLE #TMP (ID Int IDENTITY(1,1) PRIMARY KEY)
GO

INSERT INTO #TMP DEFAULT VALUES
INSERT INTO #TMP DEFAULT VALUES
INSERT INTO #TMP DEFAULT VALUES
INSERT INTO #TMP DEFAULT VALUES
INSERT INTO #TMP DEFAULT VALUES
GO

SET STATISTICS PROFILE ON
SET STATISTICS IO ON

SELECT * FROM #TMP
WHERE ID IN (1,2,3,4,5)


/* Coluna argument
OBJECT:([tempdb].[dbo].[#TMP]),
       SEEK:(
               [tempdb].[dbo].[#TMP].[ID]=(1) OR
               [tempdb].[dbo].[#TMP].[ID]=(2) OR
               [tempdb].[dbo].[#TMP].[ID]=(3) OR
               [tempdb].[dbo].[#TMP].[ID]=(4) OR
               [tempdb].[dbo].[#TMP].[ID]=(5)
            )
       ORDERED FORWARD

Repare no argument que o SQL gerou, ou seja irá acessar uma vez a tabela #TMP para cada opção do IN
podemos confirmar isso no Scan Count do statistics io

-- IO
Scan count 5, logical reads 10, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical 
reads 0, lob read-ahead reads 0. */

GO

SELECT * FROM #TMP
WHERE ID BETWEEN 1 AND 5

/* 
OBJECT:([tempdb].[dbo].[#TMP]),
       SEEK:(
              [tempdb].[dbo].[#TMP].[ID] >= (1) AND
              [tempdb].[dbo].[#TMP].[ID] <= (5)
            )
       ORDERED FORWARD

Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical 
reads 0, lob read-ahead reads 0.
Repare na diferença de IO. */