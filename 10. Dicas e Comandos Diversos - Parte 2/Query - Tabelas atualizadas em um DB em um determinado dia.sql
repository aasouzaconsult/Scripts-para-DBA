-- Tabelas de um BD alteradas, inseridas e etc, em um determinado dia

Declare @Data SmallDateTime
Set @Data = '20130815' -- Informe a Data

SELECT 
		name AS [Nome da Tabela]
,		create_date AS [Data Criação]
,		modify_date AS [Data Modificação]
FROM	Sys.Objects -- View dos objetos do banco que voce esta conectado
WHERE	type = 'u' -- Onde o tipo do objeto é U de User_table 
and		datepart(year, modify_date) = datepart(year, @Data) 
and		datepart(month, modify_date) = datepart(month, @Data) 
and		datepart(day, modify_date) = datepart(day, @Data)