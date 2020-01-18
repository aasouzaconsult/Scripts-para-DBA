/*	Query - Concatenando campos na criação de uma tabela
	Muitas vezes, nos deperamos com a necessidade de armazenar os valores existentes dentro de um 
ou mais campos que compõem uma table, esta solução pode ser realizada facilmente sem ter a necessidade 
de utilizar qualquer tipo de procedure, function ou constraint, basta definir na criação da table, 
que um determinado campo deverá armazenar os dados existentes em outros campos da mesma table.*/
 
Create Table #Tb_Teste
(codigo int identity(1,1),
 codigogrupo int,
 codigomodel int,
 Controle As (Convert(VarChar(10),codigogrupo)+Convert(VarChar(10),CodigoModel))
)
 
Insert Into #Tb_Teste Values(1,1)
Insert Into #Tb_Teste Values(2,2) 

Select * from #tb_teste