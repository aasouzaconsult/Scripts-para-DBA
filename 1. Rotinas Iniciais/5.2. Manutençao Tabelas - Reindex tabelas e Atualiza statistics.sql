SET NOCOUNT ON;
DECLARE @tablename VarChar(255),
        @ExecStr   VarChar(400),
        @maxfrag   Int,
        @Frag      Int;

SET @maxfrag = 20;

IF OBJECT_ID('tempdb.dbo.#fraglist') IS NOT NULL
  DROP TABLE #fraglist

-- Create the table.
CREATE TABLE #fraglist (
   ObjectName char(255),
   ObjectId int,
   IndexName char(255),
   IndexId int,
   Lvl int,
   CountPages int,
   CountRows int,
   MinRecSize int,
   MaxRecSize int,
   AvgRecSize int,
   ForRecCount int,
   Extents int,
   ExtentSwitches int,
   AvgFreeBytes int,
   AvgPageDensity int,
   ScanDensity decimal,
   BestCount int,
   ActualCount int,
   LogicalFrag decimal,
   ExtentFrag decimal);

-- Declare a cursor.
DECLARE CurTabelas CURSOR FOR
   SELECT name
     FROM sysObjects
    WHERE xType = 'U'

-- Open the cursor.
OPEN CurTabelas;

-- Loop through all the tables in the database.
FETCH NEXT
   FROM CurTabelas
   INTO @tablename;

WHILE @@FETCH_STATUS = 0
BEGIN;
-- Do the showcontig of all indexes of the table
   INSERT INTO #fraglist 
   EXEC ('DBCC SHOWCONTIG (''' + @tablename + ''') 
      WITH FAST, TABLERESULTS, ALL_INDEXES, NO_INFOMSGS');

   FETCH NEXT FROM CurTabelas
    INTO @tablename;
END;

-- Close and deallocate the cursor.
CLOSE CurTabelas;
DEALLOCATE CurTabelas;

-- Declare the cursor for the list of indexes to be defragged.
DECLARE CurTabs CURSOR FOR
   SELECT ObjectName, LogicalFrag
   FROM #fraglist
   WHERE LogicalFrag >= @maxfrag

-- Open the cursor.
OPEN CurTabs;

-- Loop through the indexes.
FETCH NEXT FROM CurTabs
 INTO @tablename, @Frag

WHILE @@FETCH_STATUS = 0
BEGIN;
   PRINT 'Executando DBCC DBREINDEX ' + RTRIM(@tablename) + 
         ' Fragmentação Atual é de: '  + RTRIM(CONVERT(varchar(15),@frag)) + '%';

   SET @ExecStr = 'DBCC DBREINDEX (' + RTRIM(@tablename) +  ', '''', 70)' ;

   PRINT @ExecStr;
   EXEC (@ExecStr);

   FETCH NEXT FROM CurTabs
    INTO @tablename, @Frag
END;

-- Close and deallocate the cursor.
CLOSE CurTabs;
DEALLOCATE CurTabs;

GO

exec sp_updatestats