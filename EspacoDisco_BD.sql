--CREATE TABLE #tblDatabaseSizeInformation
--    (
--      NAME SYSNAME ,
--      SpaceAvailable DECIMAL(10, 2) ,
--      SpaceUsed DECIMAL(10, 2) ,
--      DatabaseSize DECIMAL(10, 2)
--    )

--EXEC master.sys.sp_MSForEachDB ' use ? 
--INSERT INTO #tblDatabaseSizeInformation
--        ( NAME ,
--          SpaceAvailable ,
--          SpaceUsed ,
--          DatabaseSize
--        ) SELECT  db.NAME, 
--SUM(CAST(( ( mf.size * 8. ) / 1024. ) AS DECIMAL(10, 2)))
--- SUM(CAST(( ( FILEPROPERTY(mf.name, ''SpaceUsed'') * 8. ) / 1024 ) AS DECIMAL(10,
--                                                   2))) AS SpaceAvailable ,
--SUM(CAST(( ( FILEPROPERTY(mf.name, ''SpaceUsed'') * 8. ) / 1024. ) AS DECIMAL(10,
--                                                   2))) AS SpaceUsed ,
--SUM(CAST(( ( mf.size * 8. ) / 1024. ) AS DECIMAL(10, 2))) AS DatabaseSize
--FROM    sys.database_files AS df
--JOIN sys.master_files AS mf ON df.name = mf.name COLLATE Latin1_General_CS_AS
--JOIN sys.databases as db on mf.database_id = db.database_id
--WHERE   df.type = 0
--GROUP BY db.name'

select distinct tblDbInf.NAME, tblDbInf.DatabaseSize,
tblDbInf.SpaceUsed,tblDbInf.SpaceAvailable,
'(' + (select top(1) left(ms.physical_name,2) 
from sys.master_files JOIN sys.databases as db
 on tblDbInf.NAME = db.name join sys.master_files as ms
 on db.database_id = ms.database_id
 where ms.file_id = 1) +')' + ' mdf location / ' + '( '+  
( select top(1) left(ms.physical_name,2) 
from sys.master_files JOIN sys.databases as db
on tblDbInf.NAME = db.name
 join sys.master_files as ms
 on db.database_id = ms.database_id where ms.file_id = 2)+ ')' 
+ ' ldf location' as FileLocation
--into AnaliseInstancia..EspacoDisco_20201201
from #tblDatabaseSizeInformation as tblDbInf
JOIN sys.databases as db
 on tblDbInf.NAME = db.name
 join sys.master_files as ms
 on db.database_id = ms.database_id

 Select * from AnaliseInstancia..EspacoDisco_20201201

 Select * from sys.databases