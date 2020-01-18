SET QUOTED_IDENTIFIER OFF
GO
USE MASTER
GO
IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[USP_BAKZIP]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [DBO].[USP_BAKZIP]
GO
CREATE PROCEDURE USP_BAKZIP
@DBNAME VARCHAR(256),
@BAKPATH VARCHAR(1000),
@ZIPPATH VARCHAR(1000),
@TYPE VARCHAR(1) -- F (FULL BACKUP) T (TRANSACTION LOG BACKUP)
AS
--CREATED BY : MAK
--CREATED DATE : OCT 12, 2005
--OBJECTIVE: TO BACKUP THE DATABASE OR TRANSACTIONAL LOG BACKUP AND ZIP IT USING WINZIP
DECLARE @SQLSTATEMENT VARCHAR(2000)
SET @SQLSTATEMENT =''
DECLARE @BTYPE VARCHAR(25)
DECLARE @BTYPEEXT VARCHAR(4)
DECLARE @TIMESTAM VARCHAR(20)
SET @TIMESTAM=REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(25),GETDATE(),120),'-','_'),':','_'),' ','_')
IF @TYPE ='F' 
BEGIN
SET @BTYPE =' DATABASE '
SET @BTYPEEXT='.BAK'
END

IF @TYPE ='T' 
BEGIN
SET @BTYPE =' LOG '
SET @BTYPEEXT='.TRN'
END

IF @TYPE NOT IN ('T','F') 
BEGIN
GOTO ERROR
END


SET @SQLSTATEMENT = 'BACKUP ' + @BTYPE + @DBNAME+' TO DISK ="'+@BAKPATH+@DBNAME+'_'+@TIMESTAM+@BTYPEEXT+'" '
PRINT 'SQL STATEMENT'
PRINT '-------------'
PRINT @SQLSTATEMENT 
PRINT 'MESSAGE'
PRINT '-------'

EXEC (@SQLSTATEMENT)

SET @SQLSTATEMENT = 'C:\ZIP.BAT "'+@ZIPPATH+@DBNAME+'_'+@TIMESTAM+@BTYPEEXT+'.ZIP" "'+@BAKPATH+@DBNAME+'_'+@TIMESTAM+@BTYPEEXT+'"'
PRINT 'SQL STATEMENT'
PRINT '-------------'
PRINT 'MESSAGE'
PRINT '-------'
EXEC MASTER..XP_CMDSHELL @SQLSTATEMENT 
GOTO FINAL


ERROR:
PRINT 'SYNTAX : EXEC USP_BAKZIP "DATABASENAME","BAKPATH","ZIPPATH","TYPE"'
PRINT '"TYPE" SHOULD EITHER BE "F" FOR FULL BACKUP OR "T" FOR TRANSACTIONAL LOG BACKUP'
PRINT 'EXAMPLE: EXEC USP_BAKZIP "MASTER","D:\SQLDUMPS\","D:\SQLDUMPS\","F"'

GOTO FINAL

FINAL:


GO




