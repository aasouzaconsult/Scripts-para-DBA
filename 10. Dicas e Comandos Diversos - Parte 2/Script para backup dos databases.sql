--
-- script para backup dos databases
--
--
DECLARE @name VARCHAR(50)  
DECLARE @path VARCHAR(256)   
DECLARE @fileName VARCHAR(256)   
DECLARE @fileDate VARCHAR(20)  
 
SET @path = 'C:\Backup\'  
 
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
 
DECLARE db_cursor CURSOR FOR  

SELECT name 
     FROM master.dbo.sysdatabases 
     WHERE name NOT IN ('tempdb')  
 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   
 
WHILE @@FETCH_STATUS = 0   
BEGIN   
       SET @fileName = @path + @name + '_' + @fileDate + '.BAK'  
       BACKUP DATABASE @name TO DISK = @fileName  
       FETCH NEXT FROM db_cursor INTO @name   
END   
 
CLOSE db_cursor   
DEALLOCATE db_cursor 