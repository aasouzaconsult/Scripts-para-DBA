--SELECT distinct
--   OBJECT_NAME(Referenced_Object_ID) AS TabelaPai
--FROM SYS.FOREIGN_KEYS
--WHERE Parent_Object_ID = OBJECT_ID('TbRco')

SELECT distinct
   Comando = 'ALTER INDEX ALL ON ' + OBJECT_NAME(Referenced_Object_ID) + ' REBUILD;'
,  Comando2 = 'UPDATE STATISTICS [dbo].' + OBJECT_NAME(Referenced_Object_ID)
FROM SYS.FOREIGN_KEYS
WHERE Parent_Object_ID = OBJECT_ID('TbFat')