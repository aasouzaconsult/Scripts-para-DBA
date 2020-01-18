-- step 1
-- RotinasDiarias_Exec (AnaliseInstancia)

Exec AnaliseInstancia.dbo.stpVerifica_Espaco_Disco
go
Exec AnaliseInstancia.dbo.stpMonitora_ArquivosSQL
go
Exec AnaliseInstancia.dbo.StpVerifica_Utilizacao_Log
go
Exec AnaliseInstancia.dbo.StpVerifica_Backups
go
Exec AnaliseInstancia.dbo.stpLogDoSQL
go
Exec AnaliseInstancia.dbo.StpVerifica_JobsComFalha


-- step 2
-- Email_RotinasDiarias (master)
DECLARE @RotinasDiarias  NVARCHAR(MAX) ;

SET @RotinasDiarias =
	N'<font size=2 face="arial">' +
	N'<H3> ROTINAS DIARIAS DO MICROSOFT SQL SERVER </H3>' +
	N'<br>' +
	N'<br>' +
	N'Analise de Espaco em Disco:'+
	N'<br>' +
	N'<table border= "1" cellpadding= "1" cellspacing="0" width="100%">' +
	N'<tr align= center valign= middle>' +
	N'<td bgcolor="black" width="5%"><font color="white" size=2><b>DRIVE</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>TAMANHO(MB)</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>USADO(MB)</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>LIVRE(MB)</b></font></td>' +
	N'<td bgcolor="black" width="15%"><font color="white" size=2><b>LIVRE(GB)</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>LIVRE(%)</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>USADO(%)</b></font></td>' +
	N'<td bgcolor="black" width="15%"><font color="white" size=2><b>USADO SQL(MB)</b></font></td>' +
	N'<td bgcolor="black" width="20%"><font color="white" size=2><b>USADO SQL(GB)</b></font></td>' +
	N'</tr>' +

	CAST (
			(	SELECT	td = [Drive], ''
				,		td = [Tamanho (MB)], ''
				,		td = [Usado (MB)], ''
				,		td = [Livre (MB)], ''
				,		td = [Livre (MB)] / 1024, ''
				,		td = [Livre (%)], ''
				,		td = [Usado (%)], ''
				,		td = [Ocupado SQL (MB)], ''
				,		td = [Ocupado SQL (MB)] / 1024
				FROM AnaliseInstancia.dbo.EspacoEmDisco

			  FOR XML PATH('tr'), TYPE 
			) AS NVARCHAR(MAX) 
		 ) +

	N'</table>' +
	N'<br>' +
	N'<br>' +
	N'Monitoramento dos arquivos SQL:'+
	N'<br>' +
	N'<table border= "1" cellpadding= "1" cellspacing="0" width="100%">' +
	N'<tr align= center valign= middle>' +
	N'<td bgcolor="black" width="5%"><font color="white" size=2><b>ARQUIVO</b></font></td>' +
	N'<td bgcolor="black" width="50%"><font color="white" size=2><b>FILENAME</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>SIZE</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>MAXSIZE</b></font></td>' +
	N'<td bgcolor="black" width="15%"><font color="white" size=2><b>GROWTH</b></font></td>' +
	N'<td bgcolor="black" width="5%"><font color="white" size=2><b>PROX. SIZE</b></font></td>' +
	N'<td bgcolor="black" width="5%"><font color="white" size=2><b>SITUACAO</b></font></td>' +
	N'</tr>' +

	CAST (
			(	SELECT	td = Name, ''
				,		td = FileName, ''
				,		td = Size, ''
				,		td = MaxSize, ''
				,		td = Growth, ''
				,		td = Proximo_Tamanho, ''
				,		td = Situacao
				FROM AnaliseInstancia.dbo.ArquivosSQL order by Name

			  FOR XML PATH('tr'), TYPE 
			) AS NVARCHAR(MAX) 
		 ) +

	N'</table>' +	
	N'<br>' +
	N'<br>' +
	N'Utilização dos arquivos de Log:'+
	N'<br>' +
	N'<table border= "1" cellpadding= "1" cellspacing="0" width="50%">' +
	N'<tr align= center valign= middle>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>DATABASE</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>LOGSIZE</b></font></td>' +
	N'<td bgcolor="black" width="15%"><font color="white" size=2><b>LOGSIZE_USED(%)</b></font></td>' +
	N'<td bgcolor="black" width="15%"><font color="white" size=2><b>STATUS LOG</b></font></td>' +
	N'</tr>' +

	CAST (
			(	Select	td = Nm_Database, ''
				,		td = Log_Size, ''
				,		td = [Log_Space_Used(%)], ''
				,		td = status_log		
				From	AnaliseInstancia.dbo.UtilizacaoLog

			  FOR XML PATH('tr'), TYPE 
			) AS NVARCHAR(MAX) 
		 ) +

	N'</table>' +	
	N'<br>' +
	N'<br>' +
	N'Jobs com Falha:'+
	N'<br>' +
	N'<table border= "1" cellpadding= "1" cellspacing="0" width="100%">' +
	N'<tr align= center valign= middle>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>JOB</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>STATUS</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>DATA</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>TEMPO</b></font></td>' +
	N'<td bgcolor="black" width="60%"><font color="white" size=2><b>MENSAGEM</b></font></td>' +
	N'</tr>' +

	CAST (
				(	SELECT 	td = [Job_Name], ''
					,	 	td = [Status], ''
					,	 	td = [Dt_Execucao], ''
					,	 	td = [Run_Duration], ''
					,	 	td = [SQL_Message]
					FROM 	[AnaliseInstancia].[dbo].[JobsFailed]

			  FOR XML PATH('tr'), TYPE 
			) AS NVARCHAR(MAX) 
		 ) +

	N'</table>' +	
	N'<br>' +
	N'<br>' +	
	N'Backups:'+
	N'<br>' +
	N'<table border= "1" cellpadding= "1" cellspacing="0" width="40%">' +
	N'<tr align= center valign= middle>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>DATABASE</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>ARQUIVO BKP</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>DATA</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>DURACAO</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>SERVIDOR</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>RECOVERY MODEL</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>TAMANHO(KB)</b></font></td>' +
	N'</tr>' +

	CAST (
			(	Select	td = database_name, ''
				,		td = name, ''
				,		td = backup_start_date, ''
				,		td = tempo, ''
				,		td = server_name, ''
				,		td = recovery_model, ''
				,		td = tamanho		
				From	AnaliseInstancia.dbo.Backups

			  FOR XML PATH('tr'), TYPE 
			) AS NVARCHAR(MAX) 
		 ) +

	N'</table>' +
	N'<br>' +
	N'<br>' +
	N'Informações do Servidor (Configurações):'+
	N'<br>' +
	N'<table border= "1" cellpadding= "1" cellspacing="0" width="100%">' +
	N'<tr align= center valign= middle>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>ID</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>NAME</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>VALUE</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>VALUE USED</b></font></td>' +
	N'<td bgcolor="black" width="20%"><font color="white" size=2><b>DESCRICAO</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>MINIMO</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>MAXIMO</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>IS_DYNAMIC</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>IS_ADVENCED</b></font></td>' +
	N'</tr>' +

	CAST (
			(	Select	td = configuration_id, ''
				,		td = name, ''
				,		td = value, ''
				,		td = value_in_use, ''
				,		td = description, ''
				,		td = minimum, ''
				,		td = maximum, ''
				,		td = is_dynamic, ''
				,		td = is_advanced
				From	sys.configurations
				Order by
						name

			  FOR XML PATH('tr'), TYPE 
			) AS NVARCHAR(MAX) 
		 ) +

	N'</table>' +	
	N'<br>' +
	N'<br>' +
	N'Log do SQL Server:'+
	N'<br>' +
	N'<table border= "1" cellpadding= "1" cellspacing="0" width="100%">' +
	N'<tr align= center valign= middle>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>DATA/HORA</b></font></td>' +
	N'<td bgcolor="black" width="10%"><font color="white" size=2><b>PROC. INFO</b></font></td>' +
	N'<td bgcolor="black" width="80%"><font color="white" size=2><b>MENSAGEM</b></font></td>' +
	N'</tr>' +

	CAST (
			(	Select	td = LogDate, ''
				,		td = ProcessInfo, ''
				,		td = Text, ''
				From	AnaliseInstancia.dbo.LogDoSQL
				Where	Convert(varchar, LogDate, 112) = Convert(varchar, getdate() -1, 112)
				Order by
						LogDate desc

			  FOR XML PATH('tr'), TYPE 
			) AS NVARCHAR(MAX) 
		 ) +

	N'</table>' +	
	N'<br>' +
	N'<br>' +
	N'<font size=1><i><p>Informacoes geradas pelo sistema de alerta do Microsoft SQL Server.</p></i></font>' +
	N'</font>';

EXEC msdb.dbo.sp_send_dbmail 
	@profile_name = 'EmailRegina',
	@recipients='alex.souza@granjaregina.com.br;pessoalex@gmail.com',
	@subject = 'TopManager - Rotinas Diárias do SQL Server (Regina)',
	@body = @RotinasDiarias,
	@body_format = 'HTML';
	

-- step 3
-- RelatorioDiario_New (AnaliseInstancia)
EXEC dbo.uspRelatorioDiario;