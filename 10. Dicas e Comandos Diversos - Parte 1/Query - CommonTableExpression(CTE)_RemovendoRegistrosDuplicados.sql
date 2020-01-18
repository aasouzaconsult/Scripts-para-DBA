/*	Utilizando Common Table Expression, removendo registros duplicados
	Utilizado na identificação e eliminação de registros duplicados.
	
	Veja abaixo o código de exemplo: */

	Create Table #prod (
		Product_Code Varchar(10)
,		Product_Name Varchar(100))

INSERT INTO #prod(Product_Code, Product_Name) VALUES ('123','Product_1')
INSERT INTO #prod(Product_Code, Product_Name) VALUES ('234','Product_2')
INSERT INTO #prod(Product_Code, Product_Name) VALUES ('345','Product_3')
INSERT INTO #prod(Product_Code, Product_Name) VALUES ('345','Product_3')
INSERT INTO #prod(Product_Code, Product_Name) VALUES ('456','Product_4')
INSERT INTO #prod(Product_Code, Product_Name) VALUES ('567','Product_5')
INSERT INTO #prod(Product_Code, Product_Name) VALUES ('678','Product_6')
INSERT INTO #prod(Product_Code, Product_Name) VALUES ('789','Product_7')

SELECT * FROM #prod; 

With Dups as ( Select *, Row_Number() over (partition by Product_Code order By Product_Code) as RowNum from #prod ) 
Delete from Dups where rownum > 1; 

--Observe o registro duplicado 345 Product_3 foi removido. 
SELECT * FROM #prod;