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
	SELECT sys.indexes.object_id, sys.indexes.name, index_id 
	FROM sys.indexes 
	INNER JOIN sys.objects on sys.objects.object_id = sys.indexes.object_id
	WHERE sys.indexes.Object_id > 100 and sys.objects.name like @TABLE_TO_SEARCH

OPEN indexes
FETCH NEXT FROM indexes 
INTO @table_object_id, @index_name, @index_id

WHILE @@FETCH_STATUS = 0
BEGIN
      SELECT @table_name = name FROM sys.objects 
            WHERE object_id = @table_object_id
      DECLARE index_columns CURSOR FOR
            SELECT column_id, is_included_column FROM sys.index_columns 
            WHERE sys.index_columns.object_id= @table_object_id
                  AND sys.index_columns.index_id = @index_id
            ORDER BY index_column_id
      print '---------------'
      print 'Nome da tabela: ' + @table_name
      print 'Nome do índice: ' + @index_name
      print 'ID do índice: ' + convert(varchar(3),@index_id)
      print 'Colunas do índice: ' 
      OPEN index_columns

      FETCH NEXT FROM index_columns 

      INTO @column_id, @is_included_column

            WHILE @@FETCH_STATUS = 0
            BEGIN
                  DECLARE @column_name AS varchar(30)
                  SELECT @column_name = name FROM sys.columns 
                        WHERE object_id = @table_object_id
                        AND column_id = @column_id
                  IF @is_included_column = 0 print @column_name
                  ELSE print '(included)' +@column_name 
                  FETCH NEXT FROM index_columns 
                  INTO @column_id, @is_included_column
            END;
      CLOSE index_columns

      DEALLOCATE index_columns
      FETCH NEXT FROM indexes 
      INTO @table_object_id, @index_name, @index_id
END

CLOSE indexes

DEALLOCATE indexes

