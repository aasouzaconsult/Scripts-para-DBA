-- Servidor principal.: ServidorA
-- Servidor secundário: ServidorB\Teste

-- Estou no ServidorA e quero acessar ServidorB\Teste
-- Tb pega os dados da hora anterior
Select *
from [ServidorB\Teste].BancoTesteB.dbo.TbTesteB
Where Datepart(hour, DataHora) = Datepart(hour, getdate())-1
and	Convert(varchar,DataHora,112) = Convert(varchar,getdate(),112)
order by DataHora desc

---- Para inserir estas informações em uma tabela do BancoTesteA
--insert into BancoTesteA..TbTesteA
--Select *
--from [ServidorB\Teste].BancoTesteB.dbo.TbTesteB
--Where Datepart(hour, DataHora) = Datepart(hour, getdate())-1
--and	Convert(varchar,DataHora,112) = Convert(varchar,getdate(),112)
--order by DataHora desc

--Criando um linked server entre o SQL Server e o Access
--EXEC sp_addlinkedserver
--@server = 'BigSolo', -->nome do linked server
--@provider = 'Microsoft.Jet.OLEDB.4.0', -->provider de conexão para o Access
--@srvproduct = 'OLE DB Provider for Jet', -->descrição do provider utilizado na conexão
--@datasrc = 'C:\Big-Solo.mdb' --> nome do arquivo.mdb
--GO
--Select * from [BigSolo]...Produto -->Forma de acesso 
