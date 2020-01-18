/* Como encontrar objetos do Database no SQL Server?
Fala galera, essa semana, mais uma vez, precisei criar um script para uma documentação de sistema. 
Estamos montando algumas Matrizes de Rastreabilidade para um projeto no cliente e precisávamos saber 
todos os objetos que faziam parte de um determinado conjunto de tabelas. 
Como no código anterior (Como calcular a massa de dados no SQL Server?), a Engine que roda lá ainda é 
SQL Server 2000, e não temos muitas coisas que dê para fazer utilizando os recursos novos. 
O código original é pro SQL Server 2000 mas eu adaptei algumas poucas coisas rapidamente para o 2008. 
Essa execução abaixo é resultado do SQL Server 2008.
Neste caso, precisávamos encontrar todos os objetos que seriam documentados e, de acordo com a necessidade, 
migrado para a aplicação off-line que estamos atuando. Veja o código T-SQL e o resultado obtido.

por Diego Nogare

*/

-- Rodar em Modo Texto

Use AdventureWorks;
GO
SET NOCOUNT ON
/* MOSTRAR TODAS TABELAS DO SCHEMA VENDAS [SALES] */ 
print('*********************************************************') 
print('MOSTRAR TODAS TABELAS DO SCHEMA VENDAS [SALES]')
SELECT T.NAME 'TABELAS' 
FROM sys.tables T 
    INNER JOIN sys.schemas S 
        ON T.schema_id = S.schema_id 
WHERE S.name = 'Sales' 
DECLARE @TABELA VARCHAR(50) 
SET @TABELA = '%Store%'
/* RELACIONAMENTOS DE 1 NIVEL DA TABELA */ 
print('*********************************************************') 
print('RELACIONAMENTOS DE 1 NIVEL DA TABELA')
SELECT PK.TABLE_NAME 'PAI', 
       FK.TABLE_NAME 'FILHO' 
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS C 
    INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS PK 
        ON C.CONSTRAINT_NAME = PK.CONSTRAINT_NAME 
    INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS FK 
        ON C.UNIQUE_CONSTRAINT_NAME = FK.CONSTRAINT_NAME 
WHERE FK.TABLE_NAME = REPLACE(@TABELA,'%','') 
   OR PK.TABLE_NAME = REPLACE(@TABELA,'%','')
/* TODOS OS OBJETOS DA TABELA */ 
print('*********************************************************') 
print('TODOS OS OBJETOS DA TABELA')
SELECT O.NAME 'NOME', 
       REPLACE(O.type_desc,'_',' ') 'TIPO' 
FROM SYS.OBJECTS O 
    INNER JOIN SYSCOMMENTS C 
        ON O.object_id = C.ID 
WHERE C.TEXT LIKE @TABELA
/* TODAS AS CONSTRAINTS DA TABELA */ 
print('*********************************************************') 
print('TODAS AS CONSTRAINTS DA TABELA')
SELECT O2.NAME 'TABELA', 
       CL.NAME 'COLUNA', 
       O.NAME 'CONSTRAINT', 
       COM.TEXT 'CONDIÇÃO' 
FROM SYSCONSTRAINTS C 
    INNER JOIN SYSOBJECTS O 
        ON O.ID = C.CONSTID 
    INNER JOIN SYSOBJECTS O2 
        ON O2.ID = C.ID 
    INNER JOIN SYSCOLUMNS CL 
        ON CL.ID = O2.ID 
        AND CL.COLID = C.COLID 
    INNER JOIN SYSCOMMENTS COM 
        ON O.ID = COM.ID 
WHERE O2.NAME LIKE REPLACE(@TABELA,'%','') 
  AND O2.XTYPE = 'U' 
ORDER BY O2.NAME, CL.NAME, O.NAME
SET NOCOUNT OFF