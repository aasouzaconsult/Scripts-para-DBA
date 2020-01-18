--> FRAGMENTAÇÃO INTERNA - Faz com que o espaço em disco não seja utilizado de forma eficiente 
-- fazendo com que sejam utilizadas mais páginas do que o necessário.

-- (Fragmentação Interna) Quando for menor do que 75% e maior do que 60%.(avg_page_space_used_in_percent) -- REORGANIZE
-- (Fragmentação Interna) Quando for menor que 60% .(avg_page_space_used_in_percent)                      -- REBUILD

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

CREATE PROCEDURE [dbo].[PrFragmentacaoInterna]( @Database VarChar(100))
AS
BEGIN
	DECLARE @Tabela		 AS VARCHAR(1000)
	DECLARE @Indice		 AS VARCHAR(1000)
	DECLARE @FragInterna AS NUMERIC(10,3)
	DECLARE @Indexacao	 AS VARCHAR(1000)

	DECLARE FragInterna_Indices CURSOR FOR
	SELECT	Tabela = OBJECT_NAME(dt.object_id)
	,		Indice = si.name
	,		FragInterna = dt.avg_page_space_used_in_percent
	,		CASE	WHEN dt.avg_page_space_used_in_percent between 60 and 75 THEN 'REORGANIZE'
					WHEN dt.avg_page_space_used_in_percent < 60 THEN 'REBUILD'
			ELSE	'OK' 
			END as [Indexacao]
	FROM	(SELECT object_id, index_id, avg_fragmentation_in_percent, avg_page_space_used_in_percent
			 FROM sys.dm_db_index_physical_stats (DB_ID(@Database), NULL, NULL, NULL, 'DETAILED')
			 WHERE index_id <> 0) AS dt
	INNER JOIN sys.indexes si ON si.object_id = dt.object_ID AND si.index_id = dt.index_id
	Order by
			dt.avg_page_space_used_in_percent desc -- Fragmentação Interna

	OPEN FragInterna_Indices
	FETCH NEXT FROM FragInterna_Indices
	INTO @Tabela, @Indice, @FragInterna, @Indexacao

	IF SERVERPROPERTY('EngineEdition') = 3
		print '/***********************************************************************'
		print ' * Versão ENTERPRISE - Pode utilizar o REBUILD com a opção ONLINE = ON *'
		print ' ***********************************************************************/'
		print ''

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		IF @Indexacao = 'REORGANIZE'
				print 'ALTER INDEX ' + @Indice + ' ON ' + @Tabela + ' REORGANIZE; -- Fragmentação Interna(%) = ' + Convert(varchar, @FragInterna) + ' %'
		ELSE IF @Indexacao = 'REBUILD'
					print 'ALTER INDEX ' + @Indice + ' ON ' + @Tabela + ' REBUILD WITH (ONLINE = OFF); -- Fragmentação Interna(%) = ' + Convert(varchar, @FragInterna) + ' %' -- Se for SQL Server 2005 ENTERPRISE pode utilizar ONLINE = ON
		
		FETCH NEXT FROM FragInterna_Indices
		INTO @Tabela, @Indice, @FragInterna, @Indexacao
	END

	CLOSE FragInterna_Indices
	DEALLOCATE FragInterna_Indices

End

-- Execução
EXEC PrFragmentacaoInterna 'IVT'