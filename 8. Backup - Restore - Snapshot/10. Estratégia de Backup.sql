-- ########################
-- # ESTRATÉGIA DE BACKUP #
-- ########################

-- Cenário:

-- Tamanho do Banco: 10.6Gb
Use DBBackup
sp_spaceused 

-- Espaço Livre: 20Gb
EXEC xp_fixeddrives -- Espaço em disco

-- Backup Completo: 
-- - Tempo   (+/-): 00h:10m:00s
-- - Tamanho (+/-): 8Gb

-- Backup Diferencial: 
-- - Tempo   (+/-): 00h:00m:06s
-- - Tamanho (+/-): 100MB

-- Backup Log: 
-- - Tempo   (+/-): 00h:00m:01s
-- - Tamanho (+/-): 100MB

-- 01. Backup Completo as 01:00hs
-- 02. Backup Diferencial as 07:00hs
-- 03. Backup de Log as 07:30
-- 04. Backup de Log as 08:00
-- 05. Backup de Log as 08:15
-- 06. Backup de Log as 08:30
-- 07. Backup de Log as 08:45
-- 08. Backup de Log as 09:00
-- 09. Backup de Log as 09:15
-- 10. Backup de Log as 09:30
-- 11. Backup de Log as 09:45
-- 12. Backup de Log as 10:00
-- 13. Backup de Log as 10:30
-- 14. Backup de Log as 11:00
-- 15. Backup de Log as 11:30
-- 16. Backup de Log as 12:00
-- 17. Backup Diferencial as 12:30hs
-- 18. Backup de Log as 13:00
-- 19. Backup de Log as 13:30
-- 20. Backup de Log as 14:00
-- 21. Backup de Log as 14:30
-- 22. Backup de Log as 15:00
-- 23. Backup de Log as 15:30
-- 24. Backup de Log as 16:00
-- 25. Backup de Log as 16:30
-- 26. Backup de Log as 17:00
-- 27. Backup de Log as 17:30
-- 28. Backup de Log as 18:00
-- 29. Backup Diferencial as 18:30hs
-- 30. Backup de Log as 19:00
-- 31. Backup de Log as 19:15
-- 32. Backup de Log as 19:30
-- 33. Backup de Log as 19:45
-- 34. Backup de Log as 20:00
-- 35. Backup de Log as 20:15
-- 36. Backup de Log as 20:30
-- 37. Backup de Log as 20:45
-- 38. Backup de Log as 21:00
-- 39. Backup Diferencial as 21:30hs
-- 40. Backup de Log as 22:30
-- 41. Backup de Log as 23:30
-- 42. Backup de Log as 00:30

-- ###########
-- # BACKUPS #
-- ###########

-- 01. Backup Completo as 01:00hs
use master
BACKUP DATABASE DBBackup TO DISK = 'C:\Backups\Backup_Completo_0100.bak';

-- 02. Backup Diferencial as 07:00hs
use master
BACKUP DATABASE DBBackup TO DISK = 'C:\Backups\Backup_Diferencial_0700.bak' WITH DIFFERENTIAL;

-- 03. Backup de Log as 07:30
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_0730.bak';

-- 04. Backup de Log as 08:00
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_0800.bak';

-- 05. Backup de Log as 08:15
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_0815.bak';

-- 06. Backup de Log as 08:30
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_0830.bak';

-- 07. Backup de Log as 08:45
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_0845.bak';

-- 08. Backup de Log as 09:00
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_0900.bak';

-- 09. Backup de Log as 09:15
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_0915.bak';

-- 10. Backup de Log as 09:30
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_0930.bak';

-- 11. Backup de Log as 09:45
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_0945.bak';

-- 12. Backup de Log as 10:00
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_1000.bak';

-- 13. Backup de Log as 10:30
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_1030.bak';

-- 14. Backup de Log as 11:00
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_1100.bak';

-- 15. Backup de Log as 11:30
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_1130.bak';

-- 16. Backup de Log as 12:00
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_1200.bak';

-- 17. Backup Diferencial as 12:30hs
use master
BACKUP DATABASE DBBackup TO DISK = 'C:\Backups\Backup_Diferencial_1230.bak' WITH DIFFERENTIAL;

-- 18. Backup de Log as 13:00
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_1300.bak';

-- 19. Backup de Log as 13:30
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_1330.bak';

-- 20. Backup de Log as 14:00
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_1400.bak';

-- 21. Backup de Log as 14:30
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_1430.bak';

-- 22. Backup de Log as 15:00
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_1500.bak';

-- 23. Backup de Log as 15:30
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_1530.bak';

-- 24. Backup de Log as 16:00
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_1600.bak';

-- 25. Backup de Log as 16:30
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_1630.bak';

-- 26. Backup de Log as 17:00
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_1700.bak';

-- 27. Backup de Log as 17:30
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_1730.bak';

-- 28. Backup de Log as 18:00
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_1800.bak';

-- 29. Backup Diferencial as 18:30hs
use master
BACKUP DATABASE DBBackup TO DISK = 'C:\Backups\Backup_Diferencial_1830.bak' WITH DIFFERENTIAL;

-- 30. Backup de Log as 19:00
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_1900.bak';

-- 31. Backup de Log as 19:15
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_1915.bak';

-- 32. Backup de Log as 19:30
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_1930.bak';

-- 33. Backup de Log as 19:45
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_1945.bak';

-- 34. Backup de Log as 20:00
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_2000.bak';

-- 35. Backup de Log as 20:15
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_2015.bak';

-- 36. Backup de Log as 20:30
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_2030.bak';

-- 37. Backup de Log as 20:45
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_2045.bak';

-- 38. Backup de Log as 21:00
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_2100.bak';

-- 39. Backup Diferencial as 21:30hs
use master
BACKUP DATABASE DBBackup TO DISK = 'C:\Backups\Backup_Diferencial_2130.bak' WITH DIFFERENTIAL;

-- 40. Backup de Log as 22:30
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_2230.bak';

-- 41. Backup de Log as 23:30
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_23:30.bak';

-- 42. Backup de Log as 00:30
use master
BACKUP LOG		DBBackup TO DISK = 'C:\Backups\Backup_Log_0030.bak';


-- ###########
-- # RESTORE #
-- ###########

-- Deu problema as 15:20hs
RESTORE DATABASE DBBackup FROM DISK = 'C:\Backups\Backup_Completo_0100.bak' WITH REPLACE, NORECOVERY;
RESTORE DATABASE DBBackup FROM DISK = 'C:\Backups\Backup_Diferencial_1230.bak' WITH NORECOVERY;
RESTORE LOG DBBackup FROM DISK = 'C:\Backups\Backup_Log_1300.bak' WITH NORECOVERY;
RESTORE LOG DBBackup FROM DISK = 'C:\Backups\Backup_Log_1330.bak' WITH NORECOVERY;
RESTORE LOG DBBackup FROM DISK = 'C:\Backups\Backup_Log_1400.bak' WITH NORECOVERY;
RESTORE LOG DBBackup FROM DISK = 'C:\Backups\Backup_Log_1430.bak' WITH NORECOVERY;
RESTORE LOG DBBackup FROM DISK = 'C:\Backups\Backup_Log_1500.bak' WITH RECOVERY;
-- Perdeu 20 minutos de lançamentos

-- Deu problema as 22:35hs
RESTORE DATABASE DBBackup FROM DISK = 'C:\Backups\Backup_Completo_0100.bak' WITH REPLACE, NORECOVERY;
RESTORE DATABASE DBBackup FROM DISK = 'C:\Backups\Backup_Diferencial_2130.bak' WITH NORECOVERY;
RESTORE LOG DBBackup FROM DISK = 'C:\Backups\Backup_Log_2230.bak' WITH RECOVERY;
-- Perdeu 5 minutos de lançamentos




-- ###############################################
-- ### ANALIZANDO ARQUIVOS DE BACKUP - RESTORE ### 
-- ###############################################

-- Ver ultimo backup realizado
Select max(backup_start_date) From msdb..backupset
Where database_name = 'DBBackup'

/*	O comando RESTORE LABELONLY retorna informações sobre as mídias (Media Set) armazenadas em um dispositivo. 
Este comando é utilizando nos casos onde o Administrador precisa descobrir a qual conjunto de mídia aquele 
dispositivo faz parte. */
RESTORE LABELONLY 
FROM DISK = 'C:\Backups\AdventureWorks_20110429_Completo.bak' 

--Verifica Cabeçalho do arquivo de backup
/*O comando RESTORE HEADERONLY retorna informações sobre os backups (Backup Set) armazenados em um dispositivo. 
É um dos comandos mais utilizando, pois retorna para o Administrador todos os backups armazenados no dispositivo, 
seus tipos e de quais bases eles pertencem */
RESTORE HEADERONLY 
FROM DISK = 'C:\Backups\AdventureWorks_20110429_Completo.bak' 
WITH NOUNLOAD;
GO

--Verificar se o backup esta completo e legivel.(Não verifica estrutura)
/*	O comando RESTORE VERIFYONLY realiza uma checagem na integridade dos backups de um dispositivo, verificando 
se o mesmo é legível. No entanto, este comando não verifica a estrutura de dados existente dentro do backup. 
Se o backup for válido, o SQL Server retorna uma mensagem de sucesso. 
	Caso OK aparecerá: The backup set on file 1 is valid. */
RESTORE VERIFYONLY
FROM DISK = 'C:\Backups\AdventureWorks_20110429_Completo.bak'

/*	RESTORE FILELISTONLY
	O comando RESTORE FILELISTONLY retorna informações sobre os arquivos de dados e log (*.mdf, *.ndf e *.ldf) 
armazenados em um dispositivo. */
RESTORE FILELISTONLY FROM DISK = 'C:\Backups\AdventureWorks_20110429_Completo.bak'


-- ####################################
-- ### RESTAURANDO BACKUP - RESTORE ### 
-- ####################################
--Restaurando um Backup de uma base já existente (A opção Replace sobrescreve)
USE master;
RESTORE DATABASE AdventureWorks 
FROM  DISK = 'C:\Backups\AdventureWorks_20110429_Completo.bak' WITH REPLACE

--Restaurando um Backup diferencial 
USE master;
RESTORE DATABASE AdventureWorks FROM DISK = 'C:\Backups\AdventureWorks_20110429_Completo.bak' 
WITH NORECOVERY; --Restaurando apenas o Full Backup, com a opção NORECOVERY
RESTORE DATABASE AdventureWorks FROM DISK = 'C:\Backups\AdventureWorks_20110429_Diferencial.bak'
WITH RECOVERY; --Restaurando o Differential Backup, com a opção RECOVERY

--Restaurando um Backup do Log
USE master;
RESTORE LOG Backup_Alex FROM DISK = 'C:\Backups\AdventureWorks_20110429_Log.bak' WITH RECOVERY;

--Restaurando Backup de um arquivo somente
USE master;
RESTORE DATABASE AdventureWorks FILE = 'AdventureWorks_Data' 
TO DISK = N'C:\Backups\AdventureWorks_20110429_Arquivo.bak';

--Restaurando um Backup de um FileGroup
USE master;
RESTORE DATABASE AdventureWorks FILEGROUP = 'PRIMARY'
TO DISK = N'C:\Backups\AdventureWorks_20110429_Filegroup.bak';


-- ##############################################
-- ### RESTAURANDO BACKUP COM ERROS - RESTORE ### 
-- ##############################################
USE master;
--Restaurando um backup, ignorando os erros 
RESTORE DATABASE AdventureWorks FROM DISK = 'C:\Backups\AdventureWorks_20110429_Completo.bak'
WITH	CONTINUE_AFTER_ERROR
,		REPLACE;

-- ###########################
-- ### DISPOSITIVO LÓGICOS ### 
-- ###########################
/*
Para CRIAR um dispositivo lógico usando T-SQL, o SQL Server oferece um procedimento chamado sp_addumpdevice. 
Sintaxe básica para a criação de um Backup Device.*/
USE master;
--Criando um dispositivo lógico
sp_addumpdevice @devtype = 'disk', @logicalname = 'Nome_Dispositivo_Logico', @physicalname = '\\Servidor\Share\Backup.bak';

/*
Para REMOVER um dispositivo lógico usando T-SQL, utilize o procedimento sp_dropdevice. 
Sintaxe básica para a remoção de um Backup Device.*/
USE master;
--Removendo um dispositivo lógico
sp_dropdevice @logicalname = 'Nome_Dispositivo_Logico';

-- ###############################
-- ### BACKUP COM ESPELHAMENTO ### 
-- ###############################
--Sintaxe básica para a CRIAÇÃO de um backup com espelhamento.
USE master;
--Criando um backup com Espelhamento
BACKUP DATABASE AdventureWorks TO DISK = 'C:\Backups\Original.bak' 
MIRROR TO DISK='D:\Backups\Mirror.bak' WITH FORMAT;

/* Por fim, observe no final do comando o parâmetro WITH FORMAT. A cláusula FORMAT é um parâmetro opcional para o comando 
BACKUP: este comando é utilizado para escrever um novo cabeçalho na mídia de backup, sobrescrevendo o cabeçalho anterior 
e invalidando os backups anteriores.
Entretanto, para garantir que as páginas de dados do espelhamento estejam escritas da mesma forma que no backup original, 
não é possível armazenar múltiplos backups em um arquivo ou fita espelhado. Portanto, a propriedade FORMAT é obrigatória 
para a criação de cópias espelhadas. O recurso de espelhamento só está disponível na edição Enterprise e Developer. */

-- ###########################################
-- ### CONJUNTO DE MÍDIAS SET E BACKUP SET ### 
-- ###########################################
--Criando um backup com Media Set composto de três discos
BACKUP DATABASE AdventureWorks TO
DISK = 'D:\SQL2005\Backup\P1.bak', DISK = 'D:\SQL2005\Backup\P2.bak', DISK = 'D:\SQL2005\Backup\P3.bak'
WITH FORMAT, MEDIANAME = 'Nome_Conjunto_Mídia';

--CRIANDO um backup com Media Set composto de três discos (DIFFERENTIAL)
BACKUP DATABASE AdventureWorks TO
DISK = 'D:\SQL2005\Backup\P1.bak', DISK = 'D:\SQL2005\Backup\P2.bak', DISK = 'D:\SQL2005\Backup\P3.bak'
WITH MEDIANAME = 'Nome_Conjunto_Mídia', DIFFERENTIAL;

/*	Observe que foram armazenado no mesmo Midia Set (O que diferencia é o que podemos ver logo abaixo,
ou seja a opção FILE)
	Este recurso está disponível em todas as edições do SQL Server 2005.*/

--RESTAURANDO o Backup Completo do Media Set
RESTORE DATABASE AdventureWorks FROM
DISK = 'D:\SQL2005\Backup\P1.bak', DISK = 'D:\SQL2005\Backup\P2.bak', DISK = 'D:\SQL2005\Backup\P3.bak'
WITH MEDIANAME = 'Nome_Conjunto_Mídia', FILE = 1, NORECOVERY;

--Restaurando o Backup Differential do Media Set
RESTORE DATABASE AdventureWorks FROM
DISK = 'D:\SQL2005\Backup\P1.bak', DISK = 'D:\SQL2005\Backup\P2.bak', DISK = 'D:\SQL2005\Backup\P3.bak'
WITH MEDIANAME = 'Nome_Conjunto_Mídia', FILE = 2, RECOVERY;


-- #############################################
-- # Tempo restante para a conclusão do backup #
-- #############################################
SELECT
		command
,		'EstimatedEndTime' = Dateadd(ms,estimated_completion_time,Getdate())
,		'EstimatedSecondsToEnd' = estimated_completion_time / 1000
,		'EstimatedMinutesToEnd' = estimated_completion_time / 1000 / 60
,		'BackupStartTime' = start_time
,		'PercentComplete' = percent_complete
FROM	sys.dm_exec_requests
WHERE	session_id = <spid da sessão que esta rodando o backup>

-- Acha o spid da Sessão
-- Select @@SPID

-- ##########################################
-- # Backup de todos os bancos da instancia #
-- ##########################################
Use master 
GO
declare @BackupPath nvarchar(512)
,		@DB nvarchar(512)
,		@SQLCommand nvarchar(1024)

Set @BackupPath = 'C:\Backups'
Print '-- Backup Path: ' + @BackupPath

DECLARE DBCursor CURSOR FAST_FORWARD FOR 
	SELECT name FROM master..sysdatabases
	OPEN DBCursor
		FETCH NEXT FROM DBCursor INTO @DB
			WHILE @@FETCH_STATUS <> -1
				BEGIN
					IF @DB NOT IN ('distribution', 'tempdb', 'Northwind', 'AdventureWorks', 'pubs')
						Begin
							PRINT  '-- Backing up database: ' + @DB
							SELECT @SQLCommand = N'Backup database [' + @DB + '] to disk = N' + char(39) + @BackupPath + char(92) + @DB + '.bak' + char(39) + ' with init'
							PRINT  @SQLCommand
							--EXEC  (@SQLCommand)
						End
					FETCH NEXT FROM DBCursor INTO @DB
			END
	DEALLOCATE DBCursor

--http://msdn.microsoft.com/pt-br/library/ms191239.aspx -- Introdução às estratégias de backup e restauração no SQL Server
--http://msdn.microsoft.com/pt-br/library/ms178094.aspx -- Planejando a recuperação de desastres
--http://msdn.microsoft.com/pt-br/library/ms175987.aspx -- Escolhendo o modelo de recuperação para um banco de dados
--http://msdn.microsoft.com/pt-br/library/ms190190.aspx -- Considerações sobre backup e restauração de bancos de dados do sistema
--http://msdn.microsoft.com/pt-br/library/ms186858.aspx -- RESTORE
--http://msdn.microsoft.com/pt-br/library/ms189275.aspx -- Visão geral do modelo de recuperação
--http://msdn.microsoft.com/pt-br/library/ms190244.aspx -- Restaurando um banco de dados para um ponto em um backup
