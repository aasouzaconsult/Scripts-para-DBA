/*Substituir um caracter especifico existente em uma string(char, varchar, nvarchar, nchar) 
ou variável caracter.
 
Veja abaixo o código de exemplo, substituindo o caracter ponto(.) por vírgula(,):*/
 
--Exemplo 1:
select Replace(pesominimo,'.',',') from pesomedio
 
--Exemplo 2:
select Replace(10.00,'.',',')

--Exemplo 3:
Create Table #Temp
 (codigo int,
  descricao varchar(20))
 
insert into #temp values(1, 'Pedro')
insert into #temp values(2, 'Fer')
insert into #temp values(3, 'JP')
insert into #temp values(4, 'Edu')
 
Select Case Codigo
          When '1' Then Replicate('0',3)+Descricao
          When '2' Then Replicate('0',4)+Descricao
         End as Codigo
From #Temp