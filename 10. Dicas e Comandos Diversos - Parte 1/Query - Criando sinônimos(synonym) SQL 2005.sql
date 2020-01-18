/*	Uma das novidades existentes no SQL Server 2005, mas pouco conhecida e utilizada são os sinônimos. 
	Este recurso tem como objetivo proporcionar a possibilidade de criar apelidos para um ou mais 
objetos que façam parte deste sinônimo. Sua utilização facilita em muito o desenvolvimento de scripts, 
quando se existe a necessidade de utilizar objetos em locais distintos armazenados no SQL Server. 
Com esta alternativa o SQL Server torna-se ainda mais prático e flexível no desenvolvimento de blocos 
de transação, acelerando a busca de objetos na composição do código esta sendo criado.
	Para criar um sinômino é possível utilizar tables, views, funções scalar, funções in-line, 
stored procedure, extended stored procedure, assembly e filtros de replicação, sendo necessário que 
estes objetos existam fisicamente no servidor SQL Server, caso contrário a criação ou alteração deste 
sinonimo é cancelada.
	Veja abaixo o código de exemplo para se criar um novo sinônimo(synonym)*/
 
-- Create a synonym for the Product table in AdventureWorks.
USE tempdb;
GO
CREATE SYNONYM MeusProdutos
FOR AdventureWorks.Production.Product;
GO

-- Query the Product table by using the synonym.
USE tempdb;
GO
SELECT ProductID, Name
FROM MeusProdutos
WHERE ProductID < 5;
GO