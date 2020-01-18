-- Diminui arquivos e log
BACKUP LOG TopManager
WITH TRUNCATE_ONLY
-- No Shrink deve usar o Logical Name, no exemplo abaixo é Exemplo_Log, vejo em:
-- Clicando no banco > propriety > files
DBCC SHRINKFILE (N'topmanagerlog' , 0, TRUNCATEONLY)
--Shrink direto na Base
DBCC SHRINKFILE (N'topmanagerdatData' , 0, TRUNCATEONLY)