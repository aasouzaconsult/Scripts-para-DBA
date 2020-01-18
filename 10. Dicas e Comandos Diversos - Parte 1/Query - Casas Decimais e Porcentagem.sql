-- Porcentagem
Declare @Lucro Numeric(10,2)
Set @Lucro=100.25

Print 'Valor Atual:'+Convert(Char(10),@Lucro)+' '+'Valor calculado:'+Convert(Char(10),@Lucro * 0.15)
Print 'Valor Final:'+Convert(Char(10),@Lucro+(@Lucro * 0.15)) 

-- Trabalhando com casas decimais
SELECT LEN(RIGHT(135.900,LEN(135.900)-CHARINDEX('.',135.900))) as qtde

--Contando a quantidade de casas decimais em conjunto com simbolo de milhar:
select Len(Right(135.900,Len(135.900)-Charindex('.',135.900)))

--Diferentes formas de retornar somente a parte decimal:
select Charindex('.',135.900)
select Right(155.900,Charindex('.',155.900)-1) As "Parte Decimal"
Select Right(10.200,CharIndex('.',10.200)) As "Parte Decimal"
Select Right(130.200,Len(130.200)-CharIndex('.',130.200)) As "Parte Decimal"

--Retornando a diferença entre dois valores decimais:
DECLARE @Numero Money
SET @Numero = 255.55
Select @Numero - FLOOR(@NUMERO)

-- Manipulando numeros decimais
Declare @Tabela table
  (Valores Decimal(10,2))

Insert Into @Tabela Values(10.99)
Insert Into @Tabela Values(12.99)
Insert Into @Tabela Values(1.99)
Insert Into @Tabela Values(10.34)
Insert Into @Tabela Values(102.20)
Insert Into @Tabela Values(9.32)

Select * from @Tabela
Where Right(Valores,2)='99'