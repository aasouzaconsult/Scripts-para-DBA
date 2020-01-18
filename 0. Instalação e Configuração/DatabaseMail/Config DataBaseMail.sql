-- Habilitando DatabaseMail
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'Database Mail XPs', 1;
GO
RECONFIGURE
GO

-- Teste envio de e-mail
USE msdb
GO
EXEC sp_send_dbmail @profile_name = 'ProfileFabiano',
                    @recipients   = 'fabianonevesamorim@hotmail.com',
                    @subject      = 'Mensagem de teste',
                    @body         = 'Alguma coisa no corpo da Mensagem. Bla bla bla...' 
GO

/*
Dados BOL
Servidor de SMTP: smtps.bol.com.br
Porta de SMTP: 587
Requer conexão segura: sim
Meu servidor requer autenticação: sim
*/