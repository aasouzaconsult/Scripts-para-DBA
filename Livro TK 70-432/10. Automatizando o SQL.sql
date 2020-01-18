-- Criar esta procedure no Banco AdventureWorks
Use AdventureWorks
CREATE PROCEDURE dbo.asp_reindex @database SYSNAME, @fragpercent INT
AS
DECLARE @cmd        NVARCHAR(max),
        @table      SYSNAME,
        @schema     SYSNAME

--Using a cursor for demonstration purposes.  
--Could also do this with a table variable and a WHILE loop
DECLARE curtable CURSOR FOR 
SELECT DISTINCT OBJECT_SCHEMA_NAME(object_id, database_id) SchemaName, OBJECT_NAME(object_id,database_id) TableName
    FROM sys.dm_db_index_physical_stats (DB_ID(@database),NULL,NULL,NULL,'SAMPLED')
    WHERE avg_fragmentation_in_percent >= @fragpercent
FOR READ ONLY

OPEN curtable
FETCH curtable INTO @schema, @table

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @cmd = 'ALTER INDEX ALL ON ' + @database + '.' + @schema + '.' + @table + 
        ' REBUILD WITH (ONLINE = ON)'

    --Try ONLINE build first, if failure, change to OFFLINE build.
    --Offline rebuild using the ALL keyword is required if the table has XML or SPATIAL indexes
    --Offline rebuild is also required for tables with a indexes on image, text, ntext, 
    --    varchar(max), nvarchar(max), varbinary(max), and xml data types.
    --We are using the ALL keyword so that we do not have to change database context in order
    --  to retrieve the index name, since a function does not exist to get the name outside of the
    --  database context for an index.  If you need to maximize the online build operations,
    --  you will need to modify this proc to change context to the database to pick up the 
    --  index name and check the index column data types and the substitute the index name for the ALL
    --  keyword.
    BEGIN TRY
        EXEC sp_executesql @cmd
    END TRY
    BEGIN CATCH
        BEGIN
            SET @cmd = 'ALTER INDEX ALL ON ' + @database + '.' + @schema + '.' + @table + 
                ' REBUILD WITH (ONLINE = OFF)'
        
            EXEC sp_executesql @cmd
        END
    END CATCH    
    FETCH curtable INTO @schema, @table
END

CLOSE curtable
DEALLOCATE curtable
GO