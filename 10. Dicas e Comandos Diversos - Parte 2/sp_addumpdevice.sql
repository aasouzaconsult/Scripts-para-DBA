DECLARE @dev varchar(100)
DECLARE @nomefis varchar(255)
DECLARE @str varchar(255)
--IF EXISTS (SELECT name FROM tempdb..sysobjects WHERE name='tbdocaux' AND xtype='U')
--	TRUNCATE TABLE #tbdocaux
--ELSE
--CREATE TABLE #tbdocaux (cmd varchar(8000))
SELECT @dev = MIN(name) FROM sys.backup_devices
WHILE @dev IS NOT NULL
BEGIN
 	SELECT @nomefis = physical_name FROM sys.backup_devices WHERE name = @dev
	SET @str = 'EXEC sp_addumpdevice ''DISK'',''' + @dev + ''','''+ @nomefis + '''' 
    INSERT INTO #tbdocaux(cmd) VALUES(@str)
    INSERT INTO #tbdocaux(cmd) VALUES ('GO')
	SELECT @dev = MIN(name) FROM sys.backup_devices WHERE name > @dev

END
	select * from #tbdocaux
