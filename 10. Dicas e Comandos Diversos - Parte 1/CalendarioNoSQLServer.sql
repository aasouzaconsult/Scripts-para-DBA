-- Calendário no SQL Server
Declare @DataInicial	datetime
,		@DataFinal		datetime

-- Informe aqui o intervalo de datas
Set		@DataInicial = '20130801'
Set		@DataFinal = '20130816'

;With Calendario(date, Dia, Mes, Ano, DiaUtil, DiaDaSemana, Semana, NomeDoMes) as
(
	Select	@DataInicial
	,		datepart(dd,@DataInicial)
	,		datepart(mm,@DataInicial)
	,		year(@DataInicial)
	,		Case when datepart(dw, @DataInicial) in (1,7) then 0 else 1 end
	,		datename(dw, @DataInicial)
	,		datepart(wk, @DataInicial)
	,		datename(month, @DataInicial)

	Union all
	Select	date + 1
	,		datepart(dd,date + 1)
	,		datepart(mm,date + 1)
	,		year(date + 1)
	,		case when datepart(dw, date + 1) in (1,7) then 0 else 1 end
	,		datename(dw, date + 1)
	,		datepart(wk, date + 1) 
	,		datename(month, date + 1)
	from	Calendario
	Where	date + 1 <= @DataFinal
)

Select * From Calendario