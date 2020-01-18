USE [master]
-- Verifica quando o TEMPDB foi criado (durante o startup do serviço)
DECLARE @starttime datetime
SET @starttime = (SELECT crdate FROM sysdatabases WHERE name = 'tempdb' )

--Hora atual
DECLARE @currenttime datetime
SET @currenttime = GETDATE()

-- Criação das variaveis para dias, horas e minutos
DECLARE @difference_dd int
DECLARE @difference_hh int
DECLARE @difference_mi int

--Determina quantos minutos passaram desde a criação do TEMPDB 
SET @difference_mi = (SELECT DATEDIFF(mi, @starttime, @currenttime))

--Determina quantos dias passaram desde a criação do TEMPDB
SET @difference_dd = (@difference_mi/60/24)

--Subtrai os dias dos minutos
SET @difference_mi = @difference_mi - (@difference_dd*60)*24

--Determina o número de horas que passaram desde a criação do TEMPDB
SET @difference_hh = (@difference_mi/60)

-- Subtrai as horas dos minutos
SET @difference_mi = @difference_mi - (@difference_hh*60)

--Mensagem 
PRINT 'Time since SQL Server service was started: ' 
+ CONVERT(varchar, @difference_dd) + ' days ' +  
CONVERT(varchar, @difference_hh) + ' hours ' + CONVERT(varchar, @difference_mi) + ' minutes.'  