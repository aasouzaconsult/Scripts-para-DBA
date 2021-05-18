USE AdventureWorksLT2017 -- <-- informe aqui o banco de dados
GO 

CREATE TABLE #temp
  ( 
     nome_tabela    SYSNAME, 
     linhas     INT, 
     tamanho_reservado VARCHAR(50), 
     tamanho_dados     VARCHAR(50), 
     tamanho_indice    VARCHAR(50), 
     tamanho_naoUsado   VARCHAR(50) 
  ) 
 
SET nocount ON
 
INSERT #temp
EXEC Sp_msforeachtable 
  'sp_spaceused ''?'''
 
SELECT b.TABLE_CATALOG as BD,
       b.table_schema  as 'Schema',
       a.nome_tabela   as Tabela, 
       a.linhas        as 'Volumetria (count)', 
       Count(*)        as 'Qtd de Colunas?', 
       a.tamanho_dados as 'Tamanho'
FROM   #temp a 
       INNER JOIN information_schema.columns b 
               ON a.nome_tabela COLLATE database_default = 
                  b.table_name COLLATE database_default 
WHERE a.nome_tabela in ('Product', 'Customer') -- Informe as tabelas aqui, separadas por virgula (,) | Para todas, só comentar esta linhas (--)
GROUP  BY b.TABLE_CATALOG,
       b.table_schema,
	   a.nome_tabela, 
          a.linhas, 
          a.tamanho_dados 
ORDER  BY Cast(Replace(a.tamanho_dados, ' KB', '') AS INTEGER) DESC
 
DROP TABLE #temp