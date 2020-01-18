--##############################################################
--# Uma maneira mais precisa de calcular a idade de uma pessoa #
--##############################################################

Declare @DtNasc smalldatetime
Set @DtNasc = '19810515'

Select	Idade = (Year(getdate()) - year(@DtNasc)) + 
		Case 
			When month(getdate()) < month(@DtNasc) 
				Then -1 
		Else	Case 
					When month(getdate()) = month(@DtNasc) 
						 and day(getdate()) > day(@DtNasc) 
					Then - 1 
				Else 0 
				End 
		End

--#####################
--# MANIPULANDO DATAS #
--#####################

Select 
	datepart(dd, getdate()) as Dia
,	datepart(mm, getdate()) as Mes
,	datepart(yy, getdate()) as Ano

declare @Data SmallDateTime
set @Data = '20080101'
Select 
	datediff (day, @Data, GetDate()) as dias --Diferença em Dias da data que colocou
,	datediff (month, @Data, GetDate()) + 1 as Mes --Diferença em Meses da data que colocou
,	datediff (year, @Data, GetDate()) as Ano --Diferença em Anos da data que colocou
,	datediff (hour, @Data, GetDate()) as Horas
,	datediff (minute, @Data, GetDate()) as Minutos
,	datediff (second, @Data, GetDate()) as Segundos

/* Validando Datas e Numeros */
select isdate (@Data) as DtValida -- Datas
select isnumeric (123) as NumValido-- Numero

/* Conversão de date em varchar */
SELECT 'A data de hoje é: ' + CAST(@Data as varchar(11))
SELECT 'A data de hoje é: ' + CONVERT(varchar(11),@Data)

-- Acha o primeiro dia do Mes **********
Declare @Dia Char(2)
Set @Dia=Day(GetDate())
Print @Dia
SELECT Convert(Varchar(2),DAY(GETDATE())-@dia+1)+'/' + Convert(Varchar(2),Month(GetDate()))+'/'+Convert(Char(4),Year(GetDate()))

/****************************************************************************************** 
Este script permite criar a função dbo.fn_dateformat a qual possibilita a formatação de uma 
data em até 12 formatos diferentes.
Coloque o script sobre o Query Analyzer e execute o script na base de dados onde deseja que 
a função seja criada.
OBS: Se desejar, use este script como um template para desenvolver sua própria função.
*******************************************************************************************/

USE PUBS
GO
IF EXISTS (SELECT [name] FROM sysobjects WHERE id = object_id('dbo.fn_dateformat') and xtype='FN')
	DROP FUNCTION dbo.fn_dateformat
GO
CREATE FUNCTION dbo.fn_dateformat (@data smalldateTime, @formato int)
/***************************************************************************
Esta função permite formatar uma data em um dos formatos abaixo.

Parâmetros:
@data - data a ser formatada
@formato - determina o formato de saída para a data

Opções de formato:
	1 - dia/mes/ano		->> 31/08/2005 (Default)
	2 - dia-mes-ano		->> 31-08-2005	
	3 - Somente dia		->> 31
	4 - Somente Mês		->> 08
	5 - Somente Ano		->> 2005
	6 - mes/dia/ano		->> 08/31/2005
	7 - mes-dia-ano		->> 08-31-2005
	8 - Formato Longo 	->> 31 de Agosto de 2005
	9 - Formato Curto 	->> 31-Agosto-2005
	10 - Mês/Ano	 	->> Agosto/2005
	11 - Mês/Ano	 	->> 08/2005
	12 - Dia/Hora	 	->> 31-08-2005 13:14

Exemplo:SELECT dbo.fn_dateformat(getdate(),1) as [dia/mes/ano]
		SELECT dbo.fn_dateformat(getdate(),10) as [Mes/Ano]
		SELECT dbo.fn_dateformat(getdate(),12) as [Dia/Hora]

Autor: Nilton Pinheiro
Website: http://www.mcdbabrasil.com.br
Baseado no Original: http://www.sqlservercentral.com/scripts/contributions/1568.asp
*******************************************************************************/

-- Retorna data como string
RETURNS nvarchar(20)
AS
BEGIN
	DECLARE @Datafmt nvarchar(20)
	-- Verifica se a data é válida
	IF @data Is Null SET @Datafmt = ''

	-- dia-mes-ano		
	ELSE IF @formato = 2
		BEGIN
			IF Day(@data) < 10 
				SET @Datafmt = '0' + Convert(varchar(2), Day(@data))
			ELSE 
				SET @Datafmt = Convert(varchar(2),Day(@data))
			SET @Datafmt = @Datafmt + '-'
			-- concatena o mes
			IF Month(@data) < 10 
				SET @Datafmt = (@Datafmt + '0' + Convert(varchar(2), Month(@data)))
			ELSE 
				SET @Datafmt = (@Datafmt + Convert(varchar(2), Month(@data)))
			SET @Datafmt = @Datafmt + '-'
			-- concatena o ano
			SET @Datafmt = @Datafmt + (SELECT Convert(varchar(4), Year(@data)))
		END
	-- somente dia
	ELSE IF @formato = 3
		BEGIN			
			IF Day(@data) < 10 
				SET @Datafmt = ('0' + CONVERT(varchar(2), Day(@data)))
			ELSE 
				SET @Datafmt = (Convert(varchar(2), Day(@data)))
		END
	-- somente mês
	ELSE IF @formato = 4
		BEGIN			
			IF Month(@data) < 10 
				SET @Datafmt = '0' + Convert(varchar(2), Month(@data))
			ELSE 
				SET @Datafmt = Convert(varchar(2), Month(@data))
		END
	-- somente Ano
	ELSE IF @formato = 5
		BEGIN
			SET @Datafmt = (SELECT Convert(varchar(4), Year(@data)))
		END
	-- mes/dia/ano
	ELSE IF @formato = 6
		BEGIN
			IF Month(@data) < 10 
				SET @Datafmt = '0' + Convert(varchar(2), Month(@data))
			ELSE 
				SET @Datafmt = Convert(varchar(2), Month(@data))
			SET @Datafmt = @Datafmt + '/'
			-- concatena o dia
			IF Day(@data) < 10 
				SET @Datafmt = (@Datafmt + '0' + Convert(varchar(2), Day(@data)))
			ELSE 
				SET @Datafmt = (@Datafmt + Convert(varchar(2), Day(@data)))
			SET @Datafmt = @Datafmt + '/'
			-- concatena o ano
			SET @Datafmt = @Datafmt + (SELECT Convert(varchar(4), Year(@data)))
		END
	-- mes-dia-ano
	ELSE IF @formato = 7
		BEGIN
			IF Month(@data) < 10 
				SET @Datafmt = '0' + Convert(varchar(2), Month(@data))
			ELSE 
				SET @Datafmt = Convert(varchar(2), Month(@data))
			SET @Datafmt = @Datafmt + '-'
			-- concatena o dia
			IF Day(@data) < 10 
				SET @Datafmt = (@Datafmt + '0' + Convert(varchar(2), Day(@data)))
			ELSE 
				SET @Datafmt = (@Datafmt + Convert(varchar(2), Day(@data)))
			SET @Datafmt = @Datafmt + '-'
			-- concatena o ano
			SET @Datafmt = @Datafmt + (SELECT Convert(varchar(4), Year(@data)))
		END
	-- Formato Longo
	ELSE IF @formato = 8
		BEGIN
			IF Day(@data) < 10 
				SET @Datafmt = ('0' + Convert(varchar(2), Day(@data)))
			ELSE 
				SET @Datafmt =  Convert(varchar(2), Day(@data))
			SET @Datafmt = @Datafmt + ' de '
			-- concatena o mês
			SET @Datafmt = @Datafmt + CASE Month(@data)
				WHEN 1 THEN 'Janeiro'
				WHEN 2 THEN 'Fevereiro'
				WHEN 3 THEN 'Março'
				WHEN 4 THEN 'Abril'
				WHEN 5 THEN 'Maio'
				WHEN 6 THEN 'Junho'
				WHEN 7 THEN 'Julho'
				WHEN 8 THEN 'Agosto'
				WHEN 9 THEN 'Setembro'
				WHEN 10 THEN 'Outubro'
				WHEN 11 THEN 'Novembro'
				ELSE 'Dezembro'
				END		
			SET @Datafmt = @Datafmt + ' de '
			-- concatena o ano
			SET @Datafmt = @Datafmt + (SELECT Convert(varchar(4), Year(@data)))
		END
	-- Formato Curto
	ELSE IF @formato = 9
		BEGIN
			IF Day(@data) < 10 
				SET @Datafmt = ('0' + Convert(varchar(2), Day(@data)))
			ELSE 
				SET @Datafmt =  Convert(varchar(2), Day(@data))
			SET @Datafmt = @Datafmt + '-'
			-- concatena o mês
			SET @Datafmt = @Datafmt + CASE Month(@data)
				WHEN 1 THEN 'Janeiro'
				WHEN 2 THEN 'Fevereiro'
				WHEN 3 THEN 'Março'
				WHEN 4 THEN 'Abril'
				WHEN 5 THEN 'Maio'
				WHEN 6 THEN 'Junho'
				WHEN 7 THEN 'Julho'
				WHEN 8 THEN 'Agosto'
				WHEN 9 THEN 'Setembro'
				WHEN 10 THEN 'Outubro'
				WHEN 11 THEN 'Novembro'
				ELSE 'Dezembro'
				END		
			SET @Datafmt = @Datafmt + '-'
			-- concatena o ano
			SET @Datafmt = @Datafmt + (SELECT Convert(varchar(4), Year(@data)))
		END
	-- mês/ano
	ELSE IF @formato = 10
		BEGIN			
			SET @Datafmt = CASE Month(@data)
				WHEN 1 THEN 'Janeiro'
				WHEN 2 THEN 'Fevereiro'
				WHEN 3 THEN 'Março'
				WHEN 4 THEN 'Abril'
				WHEN 5 THEN 'Maio'
				WHEN 6 THEN 'Junho'
				WHEN 7 THEN 'Julho'
				WHEN 8 THEN 'Agosto'
				WHEN 9 THEN 'Setembro'
				WHEN 10 THEN 'Outubro'
				WHEN 11 THEN 'Novembro'
				ELSE 'Dezembro'
				END		
			SET @Datafmt = @Datafmt + '/'
			-- concatena o ano
			SET @Datafmt = @Datafmt + (SELECT Convert(varchar(4), Year(@data)))
		END
	-- mm/yyyy
	ELSE IF @formato = 11
			BEGIN
			IF Month(@data) < 10 
				SET @Datafmt = '0' + Convert(varchar(2), Month(@data))
			ELSE 
				SET @Datafmt = Convert(varchar(2), Month(@data))

			SET @Datafmt = @Datafmt + '/'

			-- concatena o ano
			SET @Datafmt = @Datafmt + (SELECT Convert(varchar(4), Year(@data)))
		END
	-- dd/mm/yyyy hh:mm (24h)
	ELSE IF @formato = 12
			BEGIN
			IF Day(@data) < 10 
				SET @Datafmt = ('0' + Convert(varchar(2), Day(@data)))
			ELSE 
				SET @Datafmt =  Convert(varchar(2), Day(@data))

			SET @Datafmt = @Datafmt + '/'

			-- concatena o mes
			IF Month(@data) < 10 
				SET @Datafmt = (@Datafmt + '0' + Convert(varchar(2), Month(@data)))
			ELSE 
				SET @Datafmt = (@Datafmt + Convert(varchar(2), Month(@data)))

			SET @Datafmt = @Datafmt + '/'

			-- concatena o ano
			SET @Datafmt = @Datafmt + (SELECT Convert(varchar(4), Year(@data)))
			
			-- concatena a hora
			SET @Datafmt = @Datafmt + ' ' + (SELECT Convert(varchar(5), @data,114))
		END

	-- dd/mm/yyyy (Default) = 1
	ELSE
		BEGIN
			IF Day(@data) < 10 
				SET @Datafmt = ('0' + Convert(varchar(2), Day(@data)))
			ELSE 
				SET @Datafmt =  Convert(varchar(2), Day(@data))

			SET @Datafmt = @Datafmt + '/'

			-- concatena o mes
			IF Month(@data) < 10 
				SET @Datafmt = (@Datafmt + '0' + Convert(varchar(2), Month(@data)))
			ELSE 
				SET @Datafmt = (@Datafmt + Convert(varchar(2), Month(@data)))

			SET @Datafmt = @Datafmt + '/'

			-- concatena o ano
			SET @Datafmt = @Datafmt + (SELECT Convert(varchar(4), Year(@data)))
		END

RETURN(@Datafmt)
END
GO