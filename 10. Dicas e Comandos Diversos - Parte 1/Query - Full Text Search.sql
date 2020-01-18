-- Verifica se o banco está ativado para Full-Text
-- 0 = Não ativado para Full-text
-- 1 = Ativado para Full-text
SELECT DATABASEPROPERTY('AdventureWorks','IsFulltextEnabled') AS IsFulltextEnabled

-- Ativa o banco de dados para Full-Text
sp_fulltext_database 'enable'

-- Desativa o Full-Text no banco de dados
sp_fulltext_database 'disable'

