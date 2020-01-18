DECLARE @ARQUIVO varchar(255)
DECLARE @PASTA varchar(255)
DECLARE @SqlString varchar(4000)

DECLARE @doc varchar(max) 
DEclare @doc2 XML

SET @PASTA = 'C:\Temp\'

Drop Table #Arquivos
CREATE TABLE #Arquivos (arquivo varchar (255))

INSERT INTO #Arquivos (arquivo) Exec master.dbo.xp_cmdshell 'dir C:\Temp\*.xml /b'
SELECT top 1 @ARQUIVO=arquivo FROM #Arquivos


Create Table #tmpLista (xCol XML)
Set @SqlString = 'Insert Into #tmpLista(xCol)
SELECT cast(BulkColumn as XML) 
     FROM OPENROWSET (BULK '''+ @PASTA + @ARQUIVO + ''', SINGLE_BLOB) AS xCol'
 
Execute(@SqlString)

--Update #tmpLista set xCol = replace(xCol,  'xmlns="http://www.portalfiscal.inf.br/nfe"', '')
--Update #tmpLista set xCol = replace(xCol,  'encoding="UTF-8"', '')

select * from #tmpLista

SELECT @doc=CAST(xCol AS varchar(max)) FROM #tmpLista
set @doc2 = replace(@doc,  'xmlns="http://www.portalfiscal.inf.br/nfe"', '')
SELECT 
@doc2.value('(/nfeProc/NFe/infNFe/ide/cNF)[1]', 'varchar(50)' ),
@doc2.value('(/nfeProc/NFe/infNFe/ide/serie)[1]', 'int' ),
@doc2.value('(/nfeProc/NFe/infNFe/ide/dEmi)[1]', 'datetime' ),
@doc2.value('(/nfeProc/NFe/infNFe/dest/CNPJ)[1]', 'varchar(50)' ),
@doc2.value('(/nfeProc/NFe/infNFe/dest/xNome)[1]', 'varchar(100)' )

Drop TABLE #tmpLista