/*	Inserindo dados XML através de uma variável
	Como inserir dados armazenados dentro de 
uma variável XML, em uma table, que utiliza campos XML.
Veja abaixo o código de exemplo: */
 
Create Table Produtos (
	Codigo Int Identity(1,1)
,	DadosXML XML)

Declare @vXML XML
SET @vXML = '<Raiz>
                     <Codigo>1</Codigo>
                     <Nome>Arroz</Nome>
                     </Raiz>'
GO
 
SELECT @vXML
GO
 
Insert Into Produtos(Codigo, DadosXML) Values(@vXML)
GO

select * from Produtos
