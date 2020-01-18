USE msdb

--Enviando um e-mail simples
EXEC msdb.dbo.sp_send_dbmail
     @profile_name = 'EmailSQL', 
     @recipients = 'pessoalex@gmail.com', 
     @body = 'Testando e-mail pelo SQL 2005', 
     @subject = 'Teste Email SQL 2005'

---- Enviando o resultado de uma Query em Anexo
--EXEC msdb.dbo.sp_send_dbmail
--@profile_name = 'EmailSQL',
--@recipients = 'pessoalex@hotmail.com',
--@body = 'Segue em anexo a relação de bancos de dados no servidor',
--@subject = 'Relação de bancos de dados no servidor SQL 2005',
--@query = 'SELECT [Name], [Database_ID], [Create_date] FROM master.sys.databases',
--@attach_query_result_as_file = 0
------Como Anexo
----@attach_query_result_as_file = 1,
----@query_attachment_filename = 'DBRel.txt'

/***********************************
 * Configurando E-mail Manualmente *
 ***********************************/
--http://www.devmedia.com.br/articles/viewcomp.asp?comp=6662

--USE msdb
-- Habilitar o Database Mail
--sp_configure 'show advanced options', 1;
--GO
--RECONFIGURE;
--GO
--sp_configure 'Database Mail XPs', 1;
--GO
--RECONFIGURE
--GO

----Criando uma Account (conta) para ser utilizado em um Profile
--EXECUTE sysmail_add_account_sp
--@account_name = 'AlexSQL',
--@description = 'Teste de Envio de Email SQL',
--@email_address = 'pessoalex@gmail.com',
--@display_name = 'Alex - SQL 2005',
--@replyto_address = 'pessoalex@gmail.com',
--@mailserver_name = 'smtp.gmail.com'
--@port = 25;

----Criando o Profile
--EXECUTE sysmail_add_profile_sp
--@profile_name = 'EmailSQL',
--@description = 'Perfil Envio Teste'

----Criando o Profile, associamos a conta AdventureWorks Mail a este Profile
--EXECUTE sysmail_add_profileaccount_sp
--@profile_name = 'EmailSQL',
--@account_name = 'AlexSQL',
--@sequence_number = 1 --Este número é a prioridade da Conta no Profile

--Dando acesso do Profile ao MSDB, usando o tipo de Profile public
--EXECUTE sysmail_add_principalprofile_sp
--@profile_name = 'EmailSQL',
--@principal_name = 'public', --Caso seja privado, usar private
--@is_default = 1; --Valor 1 = true; Valor 0 = false; Define se é o Padrão

---- Ver usuarios do DatabaseMail
--EXEC msdb.sys.sp_helprolemember 'DatabaseMailUserRole' ;

---- Criar usuario
-- msdb > Security

-- Informações do Profile
EXEC msdb.dbo.sysmail_help_principalprofile_sp ;

-- Status do SQL Mail
EXEC msdb.dbo.sysmail_help_status_sp
-- Start
EXEC msdb.dbo.sysmail_start_sp -- para start

EXEC msdb.dbo.sysmail_help_queue_sp @queue_type = 'mail' ;

SELECT sent_account_id, sent_date FROM msdb.dbo.sysmail_sentitems ; 

SELECT * FROM msdb.dbo.sysmail_event_log order by log_id desc