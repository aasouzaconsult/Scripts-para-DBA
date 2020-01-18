USE master
GO

CREATE PROC sp_db_growth_history
(
@dbnameParam sysname = NULL
)
AS
BEGIN

DECLARE @dbname sysname

/* Caso nenhum banco seja passado, trabalhar com o que está selecionado */

SET @dbname = COALESCE(@dbnameParam, DB_NAME())

SELECT      CONVERT(char, backup_start_date, 111) AS [Date], --yyyy/mm/dd format
      CONVERT(char, backup_start_date, 108) AS [Time],
      @dbname AS [Database Name], [filegroup_name] AS [Filegroup Name], logical_name AS [Logical Filename],
      physical_name AS [Physical Filename], CONVERT(numeric(9,2),file_size/1048576) AS [File Size (MB)],
      Growth AS [Growth Percentage (%)]
FROM
(
      SELECT      b.backup_start_date, a.backup_set_id, a.file_size, a.logical_name, a.[filegroup_name], a.physical_name,
            (
                  SELECT      CONVERT(numeric(15,2),((a.file_size * 100.00)/i1.file_size)-100)
                  FROM  msdb.dbo.backupfile i1
                  WHERE       i1.backup_set_id =
                                   (
                                         SELECT      MAX(i2.backup_set_id)
                                         FROM  msdb.dbo.backupfile i2 JOIN msdb.dbo.backupset i3
                                               ON i2.backup_set_id = i3.backup_set_id
                                         WHERE i2.backup_set_id < a.backup_set_id AND
                                               i2.file_type='D' AND
                                               i3.database_name = @dbname AND
                                               i2.logical_name = a.logical_name AND
                                               i2.logical_name = i1.logical_name AND
                                               i3.type = 'D'
                                   ) AND
                        i1.file_type = 'D'
            ) AS Growth
      FROM  msdb.dbo.backupfile a JOIN msdb.dbo.backupset b
            ON a.backup_set_id = b.backup_set_id
      WHERE b.database_name = @dbname AND
            a.file_type = 'D' AND
            b.type = 'D'
           
) as Derived
WHERE (Growth <> 0.0) OR (Growth IS NULL)
ORDER BY logical_name, [Date]

END
--Esta proc espera como parâmetro, o nome do banco de dados, e pode ser executada assim:
Exec master..sp_db_growth_history 'NewTemp'