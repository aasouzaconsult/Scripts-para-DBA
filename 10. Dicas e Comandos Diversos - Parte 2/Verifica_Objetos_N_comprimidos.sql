--Verificar objetos não comprimidos

DECLARE @database VARCHAR(50) = DB_NAME()
DECLARE @emailrecipients VARCHAR(1000) = '' 
DECLARE @emailprofile VARCHAR(50) = ''
DECLARE @compressiontype VARCHAR(4) = 'PAGE'


SET NOCOUNT ON

-- Check supplied parameters
IF @database = '' 
	BEGIN 
		PRINT 'Database not specified'
		RETURN 
	END
IF @database NOT IN (SELECT name FROM sys.databases) 
	BEGIN 
		PRINT 'Database ' + @database + ' not found on server ' + @@SERVERNAME
		RETURN 
	END
IF @emailrecipients = '' AND @emailprofile <> '' 
	BEGIN 
		PRINT 'Email profile given but recipients not specified'
		RETURN 
	END
IF @emailrecipients <> '' AND @emailprofile = '' 
	BEGIN 
		PRINT 'Email recipients given but profile not specified'
		RETURN 
	END
SET @compressiontype = UPPER(LTRIM(RTRIM(@compressiontype)))
IF @compressiontype NOT IN ('PAGE', 'ROW')
	BEGIN 
		PRINT 'CompressionType must be PAGE or ROW'
		RETURN 
	END
	
-- Declare variables
DECLARE @indexreport VARCHAR(MAX)
DECLARE @missingindexcompressiontsql VARCHAR(MAX)
DECLARE @missingindextablelist VARCHAR(MAX)
DECLARE @missingindexindexlist VARCHAR(MAX)
DECLARE @missingcompressiontablecount INT
DECLARE @missingcompressionindexcount INT
DECLARE @changeindexcompressiontsql VARCHAR(MAX)
DECLARE @changeindextablelist VARCHAR(MAX)
DECLARE @changeindexindexlist VARCHAR(MAX)
DECLARE @changecompressiontablecount INT
DECLARE @changecompressionindexcount INT
DECLARE @CurrentRow INT
DECLARE @TotalRows INT
DECLARE @Objecttype VARCHAR(10)
DECLARE @objectname VARCHAR(100)
DECLARE @command VARCHAR(1000)
DECLARE @emailsubject VARCHAR(100)
DECLARE @dynamicsql VARCHAR(MAX)               

-- Create temporary tables.
-- These are used because they're scope is greater than a tablevariable i.e. we can pull results back from dynamic sql.
IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE name LIKE '##MissingCompression%')
   DROP TABLE ##MissingCompression
IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE name LIKE '##ChangeCompression%')
   DROP TABLE ##ChangeCompression      
CREATE TABLE ##MissingCompression
					(uniquerowid INT IDENTITY ( 1 , 1 ) PRIMARY KEY NOT NULL,
                   objecttype VARCHAR(10),
                   objectname VARCHAR(100),
                   command VARCHAR(500));
CREATE TABLE ##ChangeCompression
					(uniquerowid INT IDENTITY ( 1 , 1 ) PRIMARY KEY NOT NULL,
                   objecttype VARCHAR(10),
                   objectname VARCHAR(100),
                   command VARCHAR(500));
                   
-- Work out what indexes are missing compression and build the commands for them
SET @dynamicsql =
'WITH missingcompression
     AS (SELECT ''Table''  AS objecttype,
                s.name + ''.'' + o.name AS objectname,
                ''ALTER TABLE ['' + s.name + ''].['' + o.name + ''] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = ' + @compressiontype + ');'' AS command
         FROM  ' + @database + '.sys.objects o
                INNER JOIN  ' + @database + '.sys.partitions p
                  ON p.object_id = o.object_id
                INNER JOIN  ' + @database + '.sys.schemas s
                  ON s.schema_id = o.schema_id
         WHERE  TYPE = ''u''
                AND data_compression = 0
                AND Schema_name(o.schema_id) <> ''SYS''
         UNION
         SELECT ''Index'' AS objecttype,
                i.name AS objectname,
                ''ALTER INDEX ['' + i.name + ''] ON ['' + s.name + ''].['' + o.name + ''] REBUILD WITH ( DATA_COMPRESSION = ' + @compressiontype + ');'' AS command
         FROM   ' + @database + '.sys.dm_db_partition_stats ps
                INNER JOIN ' + @database + '.sys.indexes i
                  ON ps.[object_id] = i.[object_id]
                     AND ps.index_id = i.index_id
                     AND i.type_desc <> ''HEAP''
                INNER JOIN ' + @database + '.sys.objects o
                  ON o.[object_id] = ps.[object_id]
                INNER JOIN ' + @database + '.sys.schemas s
                  ON o.[schema_id] = s.[schema_id]
                     AND s.name <> ''SYS''
                INNER JOIN ' + @database + '.sys.partitions p
                  ON p.[object_id] = o.[object_id]
                     AND data_compression = 0)
                     
-- populate temporary table ''##MissingCompression''
INSERT INTO ##MissingCompression (objecttype, objectname, command)
SELECT objecttype, objectname, command FROM missingcompression ORDER BY objectname ASC, command DESC '
exec (@dynamicsql)

SET @dynamicsql =
'WITH changecompression
     AS (SELECT ''Table''  AS objecttype,
                s.name + ''.'' + o.name AS objectname,
                ''ALTER TABLE ['' + s.name + ''].['' + o.name + ''] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = ' + @compressiontype + ');'' AS command
         FROM  ' + @database + '.sys.objects o
                INNER JOIN  ' + @database + '.sys.partitions p
                  ON p.object_id = o.object_id
                INNER JOIN  ' + @database + '.sys.schemas s
                  ON s.schema_id = o.schema_id
         WHERE  TYPE = ''u''
                AND data_compression <> 0
                AND data_compression_desc <> ''' + @compressiontype + ''' 
                AND Schema_name(o.schema_id) <> ''SYS''
         UNION
         SELECT ''Index'' AS objecttype,
                i.name AS objectname,
                ''ALTER INDEX ['' + i.name + ''] ON ['' + s.name + ''].['' + o.name + ''] REBUILD WITH ( DATA_COMPRESSION = ' + @compressiontype + ');'' AS command
         FROM   ' + @database + '.sys.dm_db_partition_stats ps
                INNER JOIN ' + @database + '.sys.indexes i
                  ON ps.[object_id] = i.[object_id]
                     AND ps.index_id = i.index_id
                     AND i.type_desc <> ''HEAP''
                INNER JOIN ' + @database + '.sys.objects o
                  ON o.[object_id] = ps.[object_id]
                INNER JOIN ' + @database + '.sys.schemas s
                  ON o.[schema_id] = s.[schema_id]
                     AND s.name <> ''SYS''
                INNER JOIN ' + @database + '.sys.partitions p
                  ON p.[object_id] = o.[object_id]
                     AND data_compression <> 0
                     AND data_compression_desc <> ''' + @compressiontype + ''' )
                     
-- populate temporary table ''##ChangeCompression''
INSERT INTO ##ChangeCompression (objecttype, objectname, command)
SELECT objecttype, objectname, command FROM changecompression ORDER BY objectname ASC, command DESC '
exec (@dynamicsql)

-- We now have populated our temporary tables (##MissingCompression & ##ChangeCompression)

-- First, loop objects with no compression.
-- For each object >
--  1) increment the counter, 
--  2) add the object name to the list for display 
--  3) generate the tsql for compression commands

		-- set initial variables
		SET @missingindexcompressiontsql = ''
		SET @missingindextablelist = ''
		SET @missingindexindexlist = ''
		SET @missingcompressiontablecount = 0
		SET @missingcompressionindexcount = 0
		SELECT @TotalRows = Count(* ) FROM ##MissingCompression
		SELECT @CurrentRow = 1

		WHILE @CurrentRow <= @TotalRows
		  BEGIN
			SELECT @Objecttype = objecttype,
						@objectname = objectname,
						@command = command
			FROM   ##MissingCompression
			WHERE  uniquerowid = @CurrentRow
		    
			SET @missingindexcompressiontsql = @missingindexcompressiontsql + @command + Char(10) + Char(10) 
		   
			IF @Objecttype = 'table'
			  BEGIN
				SET @missingindextablelist = @missingindextablelist + @objectname + Char(10)     
				SET @missingcompressiontablecount = @missingcompressiontablecount + 1
			  END
		    
			IF @Objecttype = 'index'
			  BEGIN
				SET @missingindexindexlist = @missingindexindexlist + @objectname + Char(10)
				SET @missingcompressionindexcount = @missingcompressionindexcount + 1
			  END
		    
			SELECT @CurrentRow = @CurrentRow + 1
		  END
  
  
-- Now deal with Objects that need to change compression type
-- For each object >
--  1) increment the counter, 
--  2) add the object name to the list for display 
--  3) generate the tsql for compression commands

		  -- set initial variables
		SET @changeindexcompressiontsql = ''
		SET @changeindextablelist = ''
		SET @changeindexindexlist = ''
		SET @indexreport = ''
		SET @changecompressiontablecount = 0
		SET @changecompressionindexcount = 0
		SELECT @TotalRows = Count(* ) FROM ##ChangeCompression
		SELECT @CurrentRow = 1

		WHILE @CurrentRow <= @TotalRows
		  BEGIN
			SELECT @Objecttype = objecttype,
						@objectname = objectname,
						@command = command
			FROM   ##ChangeCompression
			WHERE  uniquerowid = @CurrentRow
		    
			SET @changeindexcompressiontsql = @changeindexcompressiontsql + @command + Char(10) + Char(10)
		   
			IF @Objecttype = 'table'
			  BEGIN
				SET @changeindextablelist = @changeindextablelist + @objectname + Char(10)     
				SET @changecompressiontablecount = @changecompressiontablecount + 1
			  END
		    
			IF @Objecttype = 'index'
			  BEGIN
				SET @changeindexindexlist = @changeindexindexlist + @objectname + Char(10)
				SET @changecompressionindexcount = @changecompressionindexcount + 1
			  END
		    
			SELECT @CurrentRow = @CurrentRow + 1
		  END

		 -- Build the text output for the report  >
		 -- First for objects missing compression >
		IF (@missingcompressionindexcount + @missingcompressiontablecount) > 0
		  BEGIN
			IF (@missingcompressiontablecount) > 0
			  BEGIN
				SET @indexreport = @indexreport + 'Tables not currently utilising ' + @compressiontype + ' compression >' + Char(10) +  '--------------------------------------------' + Char(10) + @missingindextablelist + Char(13) + Char(13)
			  END      
			IF (@missingcompressionindexcount) > 0
			  BEGIN
				SET @indexreport = @indexreport + 'Indexes not currently utilising ' + @compressiontype + ' compression >' + Char(10) +  '---------------------------------------------' + Char(10) + @missingindexindexlist + Char(13) + Char(13)
			  END
		  END
	
		-- Now for objects using the incorrect compression type >
		IF (@changecompressionindexcount + @changecompressiontablecount) > 0
		  BEGIN
			IF (@changecompressiontablecount) > 0
			  BEGIN
				SET @indexreport = @indexreport + 'Tables with incorrect compression type >' + Char(10) + '--------------------------------------------' + Char(13) + Char(10) + @changeindextablelist + Char(13) + Char(10)
			  END      
			IF (@changecompressionindexcount) > 0
			  BEGIN
				SET @indexreport = @indexreport + 'Indexes with incorrect compression type >' + Char(10) + '---------------------------------------------' + Char(13) + Char(10) + @changeindexindexlist + Char(13) + Char(10)
			  END
		  END
		IF (@missingcompressionindexcount + @missingcompressiontablecount) > 0
			BEGIN
				SET @indexreport = @indexreport + char(10) + '/* TSQL to implement ' + @compressiontype + ' compression */' + Char(10) + '-----------------------------------' + Char(10) + 'USE [' + @database + ']' + Char(10) + 'GO' + Char(10) + @missingindexcompressiontsql + Char(13) + Char(10)
			END
	IF (@changecompressionindexcount + @changecompressiontablecount) > 0
			BEGIN
				SET @indexreport = @indexreport + char(10) + '/* TSQL to change to ' + @compressiontype + ' compression type */' + Char(10)  + '-------------------------------------' + Char(10) + 'USE [' + @database + ']' + Char(10) + 'GO' + Char(10) + @changeindexcompressiontsql + Char(13) + Char(10)
			END	

-- Display report and email results if there are any required actions >
IF ( (@changecompressionindexcount + @changecompressiontablecount + @missingcompressionindexcount + @missingcompressiontablecount) > 0)
	BEGIN
		-- Compression changes recommended, display them
		PRINT @indexreport
		-- If email paramters supplied, email the results too.
		IF @emailrecipients <> '' AND @emailprofile <> '' 
			BEGIN
				SET @emailsubject =  @@SERVERNAME + ' : Uncompressed object report : ' + @database + ' (' + @compressiontype + ' compression)'
				-- send email
				EXEC msdb.dbo.sp_send_dbmail
					@recipients = @emailrecipients,
					@subject = @emailsubject,
					@body = @indexreport, 
					@profile_name = @emailprofile
			END		
		END
	ELSE
		BEGIN
			PRINT 'No database objects to compress'
		END

SELECT 
	* 
FROM 
	##MissingCompression

DROP TABLE ##MissingCompression
DROP TABLE ##ChangeCompression


GO



