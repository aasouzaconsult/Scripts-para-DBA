use master 
GO

declare @BackupPath nvarchar(512),
        @DB nvarchar(512),
        @SQLCommand nvarchar(1024)

set @BackupPath = 'D:\Backup'

select @BackupPath = Substring(@BackupPath,1,Len(@BackupPath)-7) + N'\Backup'

print 'Backup Path: ' + @BackupPath

DECLARE DBCursor CURSOR FAST_FORWARD FOR 
 SELECT name FROM master..sysdatabases

OPEN DBCursor

FETCH NEXT FROM DBCursor INTO @DB

WHILE @@FETCH_STATUS <> -1
BEGIN
  IF @DB NOT IN ('distribution', 'tempdb', 'Northwind', 'AdventureWorks', 'pubs')
  begin
    PRINT  'Backing up database: ' + @DB
    SELECT @SQLCommand = N'Backup database [' + @DB + '] to disk = N' + char(39) + @BackupPath + char(92) + @DB + '.bak' + char(39) + ' with init'
    PRINT  @SQLCommand
    EXEC  (@SQLCommand)
  end

  FETCH NEXT FROM DBCursor INTO @DB
END
DEALLOCATE DBCursor