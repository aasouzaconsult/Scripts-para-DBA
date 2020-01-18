--> 1. Criar um FileGroup especifico para o FT
--> 2. Criar um Catálogo FT
--> 3. Criar o indice FT
--> 4. Consultas
  
ALTER DATABASE AdventureWorks
    ADD FILEGROUP AWFullTextFG
GO

ALTER DATABASE AdventureWorks
    ADD FILE (NAME = N'S AdventureWorksFT', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\AdventureWorks FT.ndf')
    TO FILEGROUP AWFullTextFG
GO

USE AdventureWorks
GO
CREATE FULLTEXT CATALOG ProductsFTC
    ON FILEGROUP AWFullTextFG
GO

CREATE FULLTEXT INDEX ON Production.ProductDescription(Description)
    KEY INDEX PK_ProductDescription_ProductDescriptionID
    ON ProductsFTC
    WITH CHANGE_TRACKING = AUTO
GO
-- TYPE COLUMN - Usado para identificar o tipo de coluna quando é VARBINARY(MAX) - Ex. FILESTREAM
-- LANGUAGE - Especificação do Idioma

SELECT Description
FROM Production.ProductDescription
GO
-- Retorna: 762 Linhas

-- Selecionado BIKE utilizando like
SELECT	ProductDescriptionID, Description
FROM	Production.ProductDescription
WHERE	Description like '%bike%'
-- 16 Linhas

-- FREETEXT -- Pesquisa vaga vem como padrão (fuzzy search)
-- CONSTAINS -- Pesquisa vaga deve ser informada

-- Selecionado BIKE utilizando FREETEXT
SELECT	ProductDescriptionID, Description
FROM	Production.ProductDescription
WHERE	FREETEXT(Description,N'bike')
GO
-- Retorna: 14 Linhas

-- Selecionado BIKE utilizando FREETEXTTABLE
SELECT a.ProductDescriptionID, a.Description, b.*
FROM Production.ProductDescription a
    INNER JOIN FREETEXTTABLE(Production.ProductDescription, 
        Description,N'bike') b ON a.ProductDescriptionID = b.[Key]
ORDER BY b.[Rank]
GO
-- Retorna: 14 Linhas

-- Selecionado BIKE utilizando CONSTAINS
SELECT	ProductDescriptionID, Description
FROM	Production.ProductDescription
WHERE	CONTAINS(Description,N'bike')
GO
-- Retorna: 14 Linhas

-- Selecionado BIKE utilizando CONSTAINS (Utilizando um termo de consulta)
SELECT ProductDescriptionID, Description
FROM Production.ProductDescription
WHERE CONTAINS(Description,N'"bike*"')
GO
-- Retorna: 16 Linhas

-- Pesquisas usando variantes das Palavras
-- INFLECTIONAL - Raizes de Palavras
SELECT	ProductDescriptionID, Description
FROM	Production.ProductDescription
WHERE	CONTAINS(Description,N' FORMSOF (INFLECTIONAL,ride) ')
GO

-- THESAURUS - Sinominos dos termos de pesquisa
SELECT ProductDescriptionID, Description
FROM Production.ProductDescription
WHERE CONTAINS(Description,N' FORMSOF (THESAURUS,metal) ')
GO

-- NEAR - Esta Próxima
SELECT a.ProductDescriptionID, a.Description, b.*
FROM Production.ProductDescription a INNER JOIN
    CONTAINSTABLE(Production.ProductDescription, Description,
        N'bike NEAR performance') b ON a.ProductDescriptionID = b.[Key]
ORDER BY b.[Rank]        
GO

-- Média Ponderada
SELECT a.ProductDescriptionID, a.Description, b.*
FROM Production.ProductDescription a INNER JOIN
    CONTAINSTABLE(Production.ProductDescription, Description,
        N'ISABOUT (performance WEIGHT (.8), comfortable WEIGHT (.6), 
        smooth WEIGHT (.2) , safe WEIGHT (.5), competition WEIGHT (.5))', 10) 
        b ON a.ProductDescriptionID = b.[Key]
ORDER BY b.[Rank] DESC        
GO

/* LOCAL: Arquivos de Programas\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\FTDATA
--English thesaurus file entry
<XML ID="Microsoft Search Thesaurus">
    <thesaurus xmlns="x-schema:tsSchema.xml">
	<diacritics_sensitive>0</diacritics_sensitive>
        <expansion>
            <sub>Internet Explorer</sub>
            <sub>IE</sub>
            <sub>IE5</sub>
        </expansion>
        <replacement>
            <pat>NT5</pat>
            <pat>W2K</pat>
            <sub>Windows 2000</sub>
        </replacement>
        <expansion>
            <sub>run</sub>
            <sub>jog</sub>
        </expansion>
        <expansion>
            <sub>metal</sub>
            <sub>steel</sub>
            <sub>aluminum</sub>
            <sub>alloy</sub>
        </expansion>
    </thesaurus>
</XML>
*/

--Load the updated thesaurus file
USE AdventureWorks ;
EXEC sys.sp_fulltext_load_thesaurus_file 1033;
GO

--Thesaurus
SELECT ProductDescriptionID, Description
FROM Production.ProductDescription
WHERE CONTAINS(Description,N' FORMSOF (THESAURUS,metal) ')
GO

--Stop word list
SELECT ProductDescriptionID, Description
FROM Production.ProductDescription
WHERE CONTAINS(Description,N'"bike*"')
GO

CREATE FULLTEXT STOPLIST ProductStopList;
GO

ALTER FULLTEXT STOPLIST ProductStopList ADD 'bike' LANGUAGE 1033;
GO

ALTER FULLTEXT INDEX ON Production.ProductDescription
    SET STOPLIST ProductStopList
GO