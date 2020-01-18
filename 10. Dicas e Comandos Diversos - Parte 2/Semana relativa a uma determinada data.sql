-- Semana (Acha a semana relativa a data informada)
declare @d datetime = '20100404'
select DATEPART(WW, @d)