DECLARE @idoc int
DECLARE @doc nvarchar(4000)

SET @doc =    '<nfeProc versao="1.10" xmlns="http://www.portalfiscal.inf.br/nfe">
                <NFe xmlns="http://www.portalfiscal.inf.br/nfe">
                    <infNFe versao="1.10" Id="NFe00000000000000000000000000000000000000000000">
                        <ide>
                            <cUF>23</cUF>
                            <cNF>127034026</cNF>
                            <natOp>NFe - Homologação</natOp>
                            <indPag>0</indPag>
                            <mod>55</mod>
                            <serie>55</serie>
                            <nNF>12</nNF>
                            <dEmi>2009-12-21</dEmi>
                            <tpNF>1</tpNF>
                            <cMunFG>2312106</cMunFG>
                            <tpImp>1</tpImp>
                            <tpEmis>1</tpEmis>
                            <cDV>3</cDV>
                            <tpAmb>2</tpAmb>
                            <finNFe>1</finNFe>
                            <procEmi>0</procEmi>
                            <verProc>4.7.0.16</verProc>
                        </ide>
                    </infNFe>
                </NFe>
            </nfeProc>'

-- Retirando os XMLNS
set @Doc = Replace(@Doc, 'xmlns="http://www.portalfiscal.inf.br/nfe"', '')

-- Preparando o Documento XML
EXEC sp_xml_preparedocument @idoc OUTPUT, @doc

-- Selecionando os Dados
SELECT  *  -- OU (***) SELECT  * into #TesteXML
FROM    OPENXML (@idoc, '/nfeProc/NFe/infNFe/ide', 2)
            WITH (cUF int, cNF int, natOp varchar(50), indPag int, mod int, serie int, nNF int,
				  dEmi smalldatetime, tpNF int, cMunFG int, tpImp int, tpEmis int, cDV int, tpAmb int,
				  finNFe int, procEmi int, verProc varchar(15)
)

Exec sp_xml_removedocument @idoc

-- Caso utilizar o OU (***)
-- Select * from #TesteXML
-- drop table #TesteXML