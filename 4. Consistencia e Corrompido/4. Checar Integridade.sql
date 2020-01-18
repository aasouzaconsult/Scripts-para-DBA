/**********************
 * Checar Integridade *
 **********************/
-- Você deveria habilitar o PAGE_VERIFY opção de CHECKSUM em todo banco de dados de produção.
-- Propriedades do Banco de Dados > Opções > Recuperação

DBCC CHECKDB [( 'database_name' | database_id | 0
[ , NOINDEX | { REPAIR_ALLOW_DATA_LOSS | REPAIR_FAST
| REPAIR_REBUILD } ] )]
[ WITH {[ ALL_ERRORMSGS ] [ , [ NO_INFOMSGS ] ] [ , [ TABLOCK ] ]
[ , [ ESTIMATEONLY ] ] [ , [ PHYSICAL_ONLY ] ] | [ , [ DATA_PURITY ] ] } ]

--Observação:
--Para realizar estes cheques, DBCC CHECKDB executa os comandos seguintes:
-- DBCC CHECKALLOC - to check the page allocation of the database
-- DBCC CHECKCATALOG - to check the database catalog
-- DBCC CHECKTABLE - for each table and view in the database to check the structural integrity

-- Exemplos:
DBCC CHECKDB ('DB_TK432')
DBCC CHECKDB ('DB_TK432') WITH NO_INFOMSGS, ALL_ERRORMSGS