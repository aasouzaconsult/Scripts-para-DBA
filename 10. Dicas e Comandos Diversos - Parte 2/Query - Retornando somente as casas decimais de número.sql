/*	Retornando somente as casas decimais de número
	A dica de hoje tem o objetivo de demonstrar como realizar uma simples query, quer retorne somente 
	as casas decimais de um conjunto de valores numéricos. */
	
Declare @Tabela table (Valores Decimal(10,2)) 

Insert Into @Tabela Values(10.99) 
Insert Into @Tabela Values(12.99) 
Insert Into @Tabela Values(1.99) 
Insert Into @Tabela Values(10.34) 
Insert Into @Tabela Values(102.20) 
Insert Into @Tabela Values(9.32) 

SELECT Right(Valores,2) FROM @Tabela 

SELECT Valores - CAST(Valores AS INT) FROM @Tabela