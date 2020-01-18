-- Gera script para recriação dos índices já existentes em um Banco de Dados SQL 2005

DECLARE @table_object_id AS int
DECLARE @index_id AS int
DECLARE @index_name AS varchar(60)
DECLARE @table_name AS varchar(30)
DECLARE @clause AS varchar(30)
DECLARE @column_id AS int
DECLARE @is_included_column AS bit
DECLARE @TABLE_TO_SEARCH AS Varchar(30)

SET @TABLE_TO_SEARCH = ''

IF @TABLE_TO_SEARCH = '' SET @TABLE_TO_SEARCH = '%%'

DECLARE indexes CURSOR FOR 
SELECT 	sys.indexes.object_id, sys.indexes.name, index_id 
FROM 	sys.indexes 
JOIN 	sys.objects on sys.objects.object_id = sys.indexes.object_id
WHERE 	sys.indexes.Object_id > 100 and sys.objects.name like @TABLE_TO_SEARCH
AND 	sys.indexes.name like 'regina_%'
ORDER BY sys.indexes.name

OPEN indexes
FETCH NEXT FROM indexes 
INTO @table_object_id, @index_name, @index_id

WHILE @@FETCH_STATUS = 0
BEGIN
      	DECLARE @QueryExists AS VARCHAR(8000)
	DECLARE @QueryDrop AS VARCHAR(8000)
	DECLARE @Query AS VARCHAR(8000)

	SET @QueryExists = 'IF EXISTS (SELECT * FROM dbo.sysindexes WHERE id = object_id(N''[dbo].['
	SET @QueryDrop = 'DROP INDEX '
	SET @Query = 'CREATE INDEX '
      
	SELECT @table_name = name 
	FROM sys.objects 
      	WHERE object_id = @table_object_id
      
	DECLARE index_columns CURSOR FOR
	SELECT column_id, is_included_column FROM sys.index_columns 
	WHERE sys.index_columns.object_id= @table_object_id
	AND sys.index_columns.index_id = @index_id
	ORDER BY index_column_id
	
	SET @QueryExists = @QueryExists + @table_name + ']'') AND name = ''' + @index_name + ''')'		
	SET @QueryDrop = @QueryDrop + @table_name + '.' + @index_name 
	SET @Query = @Query + @index_name + ' ON ' + @table_name + '('

	DECLARE @EqualityInequalityColumns AS VARCHAR(8000)
	DECLARE @Included AS Varchar(8000)
	SET @EqualityInequalityColumns = ''
	SET @Included = ''         
      
	OPEN index_columns

	FETCH NEXT FROM index_columns 
	INTO @column_id, @is_included_column

	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @column_name AS varchar(30)
					
		SELECT @column_name = name FROM sys.columns 
		WHERE object_id = @table_object_id
		AND column_id = @column_id

		IF @is_included_column = 0 SET @EqualityInequalityColumns = @EqualityInequalityColumns + @column_name + ', '
		ELSE SET @Included = @Included + @column_name + ', '

		FETCH NEXT FROM index_columns 
		INTO @column_id, @is_included_column
	END

	CLOSE index_columns

	SET @EqualityInequalityColumns = SUBSTRING(@EqualityInequalityColumns, 0, LEN(@EqualityInequalityColumns))
	IF LEN(@Included) > 0
	BEGIN
		SET @Included = SUBSTRING(@Included, 0, LEN(@Included))
		SET @Query = @Query + @EqualityInequalityColumns + ') INCLUDE (' + @Included + ')'
	END

	ELSE
	BEGIN 
		SET @Query = @Query + @EqualityInequalityColumns + ')'
	END

	Print @QueryExists
	Print @QueryDrop
	Print @Query	
	Print 'GO'
	Print ''

	DEALLOCATE index_columns
	FETCH NEXT FROM indexes 
	INTO @table_object_id, @index_name, @index_id
END

CLOSE indexes

DEALLOCATE indexes
