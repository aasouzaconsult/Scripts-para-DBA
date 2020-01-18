/*	Criar funções no SQL Server, sabendo que toda e qualquer função deverá retornar um valor 
obrigatóriamente.*/
use DBteste

Create table TbCidades (
	CdCidade int identity(1,1) primary key
,	NmCidade varchar(30)
,	ObsCidade varchar(50)
)

insert into TbCidades values
	('São Paulo', 'Muita poluição')
,	('Rio de Janeiro', 'Muito assalto')
,	('Minas Gerais', 'Muito Queijo') 

select * from TbCidades

-- ***************************************
-- Criando Function - InLine - Table Value
-- ***************************************
IF OBJECT_ID ('Fun_Cidade') IS NOT NULL
	DROP function Fun_Cidade
GO
Create Function Fun_Cidade (@NomeCidade VarChar(100))
Returns Table
As
Return ( Select * from TbCidades Where NmCidade like @NomeCidade)

--Executando
Select * from Fun_Cidade ('%São%')

-- *************************
-- Criando Function - Scalar
-- *************************
IF OBJECT_ID ('Fun_Scalar_Valor') IS NOT NULL
	DROP function Fun_Scalar_Valor
GO
Create Function Fun_Scalar_Valor(@Numero Int)
Returns Int
As
Begin
	Declare @Numero2 int = 1
	--Set @Numero2 = 1
	Set @Numero2 = @Numero2 + @Numero
	Return (@Numero2)
End

--Executando
select dbo.Fun_Scalar_Valor (10)

-- ****************************************************
-- Criando Function - Multi - Statament - Table - Value
-- ****************************************************
IF OBJECT_ID ('Fun_Multi_Statament_Tabela') IS NOT NULL
	DROP function Fun_Multi_Statament_Tabela
GO
Create Function Fun_Multi_Statament_Tabela (@Id Int)
Returns @Tabela1 Table (codigo int, descricao varchar(10))
As
Begin
--With tabela1(codigo,descricao)
	Insert @Tabela1
	Select Codigo, Descricao from Tabela1 --Where Codigo = @Id
	Return
End
go
--Executando
Select * from Fun_Multi_Statament_Tabela (1) 