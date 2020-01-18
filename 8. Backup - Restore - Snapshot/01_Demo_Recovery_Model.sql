--DEMO RECOVERY MODEL
	
--CRIA BANCO PARA RECOVERY MODEL
IF EXISTS (SELECT NULL FROM SYS.DATABASES WHERE NAME = 'SQLSERVER_RS_RECOVERY')
           DROP DATABASE SQLSERVER_RS_RECOVERY
CREATE DATABASE SQLSERVER_RS_RECOVERY
ON PRIMARY
(NAME='SQLSERVER_RS_RECOVERY', FILENAME='C:\temp\SQLServerRS\Dados\SQLSERVER_RS_RECOVERY.mdf')
LOG ON
(NAME = 'SQLSERVER_RS_RECOVERY_LOG', FILENAME = 'C:\temp\SQLServerRS\Log\SQLSERVER_RS_RECOVERY_Log.ldf')
GO


--VERIFICAR MODELO DE RECUPERAÇÃO DE TODAS AS BASES
SELECT NAME, RECOVERY_MODEL_DESC
  FROM SYS.DATABASES
 WHERE NAME = 'SQLSERVER_RS_RECOVERY'
 

 --ALTERDAR MODELO DE RECUPERAÇÃO DE UMA BASE
 ALTER DATABASE SQLSERVER_RS_RECOVERY SET RECOVERY SIMPLE
 ALTER DATABASE SQLSERVER_RS_RECOVERY SET RECOVERY FULL
 ALTER DATABASE SQLSERVER_RS_RECOVERY SET RECOVERY BULK_LOGGED

 
 --OBSERVAÇÕES IMPORTANTES

 /*
	BULK_LOGGED: 
		* Aumenta consideravelmente o tamanho dos backups de log, pois carrega todos os extents continentes das páginas
		* Não permite restore point in time.

	FULL:
		* Exige a realização de backups de logs periódicos, para controle de tamanho do Log de Transações (.ldf)

	SIMPLE:
		* Mais facilidade de Administração, porém sem muitas possibilidades de Restore, pois permite restauração somente até  
		   final do backup full
	

 */