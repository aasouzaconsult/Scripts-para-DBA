-- Tabela com Row Compression
CREATE TABLE Tmp_Row_Compression(ID      Int IDENTITY(1,1) PRIMARY KEY, 
                                 Nome    VarChar(200),
                                 Nome2   Char(200)     DEFAULT NEWID(),
                                 Nome3   Char(200)     DEFAULT NEWID(),
                                 Data    DateTime      DEFAULT GetDate(),
                                 Data1   DateTime      DEFAULT GetDate(),
                                 Valor   Numeric(18,4) DEFAULT 10.5,
                                 Inteiro BigInt        DEFAULT 10)
WITH (DATA_COMPRESSION = ROW);
GO
-- Tabela com Page Compression
CREATE TABLE Tmp_Page_Compression(ID INT IDENTITY(1,1) PRIMARY KEY, 
                                 Nome    VarChar(200),
                                 Nome2   Char(200)     DEFAULT NEWID(),
                                 Nome3   Char(200)     DEFAULT NEWID(),
                                 Data    DateTime      DEFAULT GetDate(),
                                 Data1   DateTime      DEFAULT GetDate(),
                                 Valor   Numeric(18,4) DEFAULT 10.5,
                                 Inteiro BigInt        DEFAULT 10)
WITH (DATA_COMPRESSION = Page);
GO
-- Tabela sem Compression
CREATE TABLE Tmp_Sem_Compression(ID INT IDENTITY(1,1) PRIMARY KEY, 
                                 Nome    VarChar(200),
                                 Nome2   Char(200)     DEFAULT NEWID(),
                                 Nome3   Char(200)     DEFAULT NEWID(),
                                 Data    DateTime      DEFAULT GetDate(),
                                 Data1   DateTime      DEFAULT GetDate(),
                                 Valor   Numeric(18,4) DEFAULT 10.5,
                                 Inteiro BigInt        DEFAULT 10)
GO

SET NOCOUNT ON 
DECLARE @I INT
SET @I = 0 
WHILE @I < 100000
BEGIN
  INSERT INTO Tmp_Row_Compression (Nome) VALUES('Test Row Compression')
  SET @I = @I + 1; 
END
GO

SET NOCOUNT ON 
DECLARE @I INT
SET @I = 0 
WHILE @I < 100000
BEGIN
  INSERT INTO Tmp_Page_Compression(Nome) VALUES('Test Page Compression')
  SET @I = @I + 1; 
END
GO

SET NOCOUNT ON 
DECLARE @I INT
SET @I = 0 
WHILE @I < 100000
BEGIN
  INSERT INTO Tmp_Sem_Compression (Nome) VALUES('Test Sem Compression')
  SET @I = @I + 1; 
END
GO

EXEC dbo.sp_SpaceUsed Tmp_Row_Compression
/* 
Data = 12904 KB, 12 MB
Reserved = 13000 KB, 12 MB
Index_Size = 56 KB
Unused = 40 KB
*/
GO

EXEC dbo.sp_SpaceUsed Tmp_Page_Compression
/* 
Data = 9056 KB, 8 MB
Reserved = 9160 KB, 8 MB
Index_Size = 48 KB
Unused = 56 KB
*/
GO
EXEC dbo.sp_SpaceUsed Tmp_Sem_Compression
/* 
Data = 47064 KB, 45 MB
Reserved = 47304 KB, 46 MB
Index_Size = 184 KB
Unused = 56 KB
*/
GO
DBCC SHOWCONTIG('Tmp_Row_Compression')
-- Pages Scanned : 1613
GO
DBCC SHOWCONTIG('Tmp_Page_Compression')
-- Pages Scanned : 1133
GO
DBCC SHOWCONTIG('Tmp_Sem_Compression')
-- Pages Scanned : 5883
/*
Resultados Finais.
-----------------------------------------------------------------
|_______Tabela________|CPU___|Writes_|Duration__|Tamanho_|Pages_|
|Tmp_Row_Compression  |10656 |1617   |45809	    |12 MB	 |1613  |
|Tmp_Page_Compression |11359 |1142   |44118	    |8 MB    |1133  |
|Tmp_Sem_Compression  |10032 |5914   |46873	    |46 MB   |5883  |
-----------------------------------------------------------------

Compression é sem dúvida umas das melhores features do SQL Server 2008, fiz alguns testes
para ver como isso funciona na prática e fiquei bem contente com o resultado.

Baseados nos resultados acima, podemos observar 3 pontos importantes, CPU, Writes e Tamanho da tabela.

CPU – Como era de se esperar o algoritmo de nossos amigos Lempel e Ziv utilizados na compactação por 
página consome mais recurso de CPU, por outro lado, no nosso exemplo teve o melhor desempenho em 
relação a compactação dos dados consumindo apenas 1133 páginas.

Writes – Em relação ao número de writes confesso que fiquei admirado, mesmo sabendo que o SQL vai 
compactar os dados e tal, ao comparar o número de writes da tabela sem compression com as tabelas 
com compression é de se espantar.

Tamanho – Podemos observar que a compressão dos dados foi fantástica, tanto para compression por 
Row quanto por Page. Show de bola.

Obs.: Rodei o SQL na minha máquina e durante a execução continuei trabalhando, acessando disco, 
compilando projeto e por ai vai, ou seja, os resultados podem mudar bastante caso você repita os 
testes em uma máquina mais “tranqüila“ :-)  Se você fizer os testes me mande o resultado... */