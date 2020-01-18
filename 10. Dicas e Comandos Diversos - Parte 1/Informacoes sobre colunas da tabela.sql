-- Informacoes sobre colunas da tabela
--
USE DB_Mundo;
SELECT    name AS column_name,  
                TYPE_NAME(system_type_id) AS column_type, 
                max_length,
                collation_name,
                is_nullable
FROM sys.columns
WHERE object_id = OBJECT_ID('dbo.cidades');