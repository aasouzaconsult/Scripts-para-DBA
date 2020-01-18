--> FRAGMENTAÇÃO EXTERNA - Ocorre quando as páginas dos índices não estão fisicamente ordenadas.

-- (Fragmentação Externa) Quando for maior do que 10% e menor do que 15%.(avg_fragmentation_in_percent) -- REORGANIZE
-- (Fragmentação Externa) Quando for maior que 15%.(avg_fragmentation_in_percent)                       -- REBUILD

Set ANSI_NULLS ON
Set QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[PrFragmentacaoExterna]( @Database VarChar(100))
AS
BEGIN
	DECLARE @Tabela		 AS VARCHAR(1000)
	DECLARE @Indice		 AS VARCHAR(1000)
	DECLARE @FragExterna AS NUMERIC(10,3)
	DECLARE @Indexacao	 AS VARCHAR(1000)

	DECLARE FragExterna_Indices CURSOR FOR
	SELECT	Tabela = OBJECT_NAME(dt.object_id)
	,		Indice = si.name
	,		FragExterna = dt.avg_fragmentation_in_percent --as [Fragmentação Externa]
	,		CASE	WHEN dt.avg_fragmentation_in_percent between 5 and 30 THEN 'REORGANIZE'
					WHEN dt.avg_fragmentation_in_percent > 30 THEN 'REBUILD'
			ELSE	'OK'
			END		as [Indexacao]
	FROM	(SELECT object_id, index_id, avg_fragmentation_in_percent, avg_page_space_used_in_percent
			 FROM sys.dm_db_index_physical_stats (DB_ID(@Database), NULL, NULL, NULL, 'DETAILED')
			 WHERE index_id <> 0) AS dt
	INNER JOIN sys.indexes si ON si.object_id = dt.object_ID AND si.index_id = dt.index_id
	Order by
			dt.avg_fragmentation_in_percent desc -- Fragmentação Externa 

	OPEN FragExterna_Indices
	FETCH NEXT FROM FragExterna_Indices
	INTO @Tabela, @Indice, @FragExterna, @Indexacao

	IF SERVERPROPERTY('EngineEdition') = 3
		print '/***********************************************************************'
		print ' * Versão ENTERPRISE - Pode utilizar o REBUILD com a opção ONLINE = ON *'
		print ' ***********************************************************************/'
		print ''

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		IF @Indexacao = 'REORGANIZE'
				print 'ALTER INDEX ' + @Indice + ' ON ' + @Tabela + ' REORGANIZE; -- Fragmentação Externa(%) = ' + Convert(varchar, @FragExterna) + ' %'
		ELSE IF @Indexacao = 'REBUILD'
					print 'ALTER INDEX ' + @Indice + ' ON ' + @Tabela + ' REBUILD WITH (ONLINE = ON); -- Fragmentação Externa(%) = ' + Convert(varchar, @FragExterna) + ' %' 
					-- Se for SQL Server 2005 ENTERPRISE pode utilizar ONLINE = ON
		
		FETCH NEXT FROM FragExterna_Indices
		INTO @Tabela, @Indice, @FragExterna, @Indexacao
	END

	CLOSE FragExterna_Indices
	DEALLOCATE FragExterna_Indices
END

-- Execução
EXEC PrFragmentacaoExterna 'TopManager'



-- TOTAL
print 'Fragmentação Externa'
print ''
EXEC PrFragmentacaoExterna 'IVT'
GO
print ''
print 'Fragmentação Interna'
print ''
EXEC PrFragmentacaoInterna 'IVT'