DECLARE @MIN_INDEX_ADVANTAGE AS INT
DECLARE @Advantage AS DECIMAL(19,3)
DECLARE @ID AS INT
DECLARE @TableStatement AS VARCHAR(80)
DECLARE @Equality AS VARCHAR(1000)
DECLARE @Inequality AS VARCHAR(1000)
DECLARE @Included AS VARCHAR (8000)
DECLARE @Handler AS INT

SET @MIN_INDEX_ADVANTAGE = 0

DECLARE MissingIndexes CURSOR FOR
SELECT index_advantage AS Advantage, mid.object_id AS ID, mid.Statement AS TableStatement, mid.Equality_columns AS Equality, mid.inequality_columns AS Inequality, included_columns AS Included, mig.index_handle AS Handler 
FROM(
	SELECT (user_seeks + user_scans) * avg_total_user_cost * (avg_user_impact * 0.01) AS index_advantage, migs.* 
		FROM sys.dm_db_missing_index_group_stats migs 
	) AS migs_adv, 
   sys.dm_db_missing_index_groups mig, 
   sys.dm_db_missing_index_details mid 
WHERE 
   migs_adv.group_handle = mig.index_group_handle and 
   mig.index_handle = mid.index_handle and
   index_advantage > @MIN_INDEX_ADVANTAGE
ORDER BY migs_adv.index_advantage DESC 

OPEN MissingIndexes
FETCH NEXT FROM MissingIndexes 
INTO @Advantage, @ID, @TableStatement, @Equality, @Inequality, @Included, @Handler

WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE @Columns AS Varchar(2000)
	SET @Columns = ''

	IF @Equality IS NOT NULL SET @Columns = @Columns + @Equality
	IF @Inequality IS NOT NULL AND @Equality IS NOT NULL SET @Columns = @Columns + ', ' + @Inequality
	IF @Inequality IS NOT NULL AND @Equality IS NULL SET @Columns = @Inequality

	IF @Included IS NULL
		print('/* ' + CONVERT(VARCHAR(14), @Advantage) + '% */ CREATE INDEX I_MS_' + convert(varchar(8), @Handler)) + ' ON ' + @TableStatement + ' (' + @Columns + ')'
	ELSE
		print('/* ' + CONVERT(VARCHAR(14), @Advantage) + '% */ CREATE INDEX I_MS_' + convert(varchar(8), @Handler)) + ' ON ' + @TableStatement + ' (' + @Columns + ') INCLUDE (' + @Included + ')'

	FETCH NEXT FROM MissingIndexes 
	INTO @Advantage, @ID, @TableStatement, @Equality, @Inequality, @Included, @Handler
END

CLOSE MissingIndexes
DEALLOCATE MissingIndexes
