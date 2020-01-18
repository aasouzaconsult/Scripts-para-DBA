--Desanexa o banco
USE [master]
GO
sp_detach_db @dbname = N'adventureworks'
GO



--Cria o banco com os arquivos que foram desanexados
--
USE [master]
GO
CREATE DATABASE [AdventureWorks] ON
(filename = 'C:\Dados2\AdventureWorks_Data.mdf'),
(filename = 'C:\Dados2\AdventureWorks_Log.ldf')
for attach

