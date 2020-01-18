DECLARE @TopManagerSSMS  NVARCHAR(MAX) ;

SET @TopManagerSSMS =
    N'<font size=2 face="arial">' +
    N'<H3> USUÁRIOS TOPMANAGER LOGADOS VIA SSMS </H3>' +
    N'<br>' +
    N'<br>' +
    N'<table border= "1" cellpadding= "1" cellspacing="0" width="100%">' +
    N'<tr align= center valign= middle>' +
    N'<td bgcolor="black" width="15%"><font color="white" size=2><b>Login</b></font></td>' +
    N'<td bgcolor="black" width="15%"><font color="white" size=2><b>SPID</b></font></td>' +
    N'<td bgcolor="black" width="15%"><font color="white" size=2><b>MAQUINA</b></font></td>' +
    N'<td bgcolor="black" width="30%"><font color="white" size=2><b>PROGRAMA</b></font></td>' +
    N'<td bgcolor="black" width="25%"><font color="white" size=2><b>COMANDO</b></font></td>' +
    N'</tr>' +

    CAST (
            (   SELECT td = loginame
                     , ''
                     , td = spid
                     , ''
                     , td = hostname
                     , ''
                     , td = program_name
                     , ''
                     , td = 'kill ' + convert(varchar,spid) + ' -- ' + hostname
                  FROM master..sysprocesses 
                 WHERE loginame = 'TopManager'
                   AND program_name <> '.Net SqlClient Data Provider'
                   AND hostname <> 'PC6210'
                 ORDER BY hostname

                FOR XML PATH('tr'), TYPE
                
            ) AS NVARCHAR(MAX) 
         ) +

    N'</table>' +
    N'<br>' +
    N'<br>' +
    

    N'<font size=1><p> SELECT loginame                                                                  </p></font>' +
    N'<font size=1><p>      , spid                                                                      </p></font>' +
    N'<font size=1><p>      , hostname                                                                  </p></font>' +
    N'<font size=1><p>      , program_name                                                              </p></font>' +
    N'<font size=1><p>      , comando = convert(varchar, ''kill '' + convert(varchar,spid) + '' -- '' + hostname) </p></font>' +
    N'<font size=1><p>   FROM master..sysprocesses                                                      </p></font>' +
    N'<font size=1><p>  WHERE loginame = ''TopManager''                                                 </p></font>' +
    N'<font size=1><p>    AND program_name <> ''.Net SqlClient Data Provider''                          </p></font>' +
    N'<font size=1><p>    AND hostname <> ''PC6210''                                                    </p></font>' +
    N'<font size=1><p>  ORDER BY hostname                                                               </p></font>' +
    N'<br>'+
    N'<br>'+
    N'<font size=1><i><p>Informacoes geradas pelo sistema de alerta do Microsoft SQL Server.</p></i></font>';

EXEC msdb.dbo.sp_send_dbmail 
    @profile_name = 'EmailRegina',
    @recipients='alex.souza@granjaregina.com.br;pessoalex@gmail.com',
    @subject = 'TopManager - Usuarios logados via SSMS',
    @body = @TopManagerSSMS,
    @body_format = 'HTML';