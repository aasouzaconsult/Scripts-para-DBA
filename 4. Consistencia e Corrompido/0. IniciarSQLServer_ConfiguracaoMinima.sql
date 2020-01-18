-- http://msdn.microsoft.com/pt-br/library/ms162773.aspx -- Utilitário sqlcmd
-- http://msdn.microsoft.com/pt-br/library/ms165702.aspx -- Usando o utilitário sqlcmd (SQL Server Express)
-- http://msdn.microsoft.com/pt-br/library/ms190737.aspx -- Usando as opções de inicialização do serviço do SQL Server
-- http://msdn.microsoft.com/pt-br/library/ms180965.aspx -- Como iniciar uma instância do SQL Server (sqlservr.exe)


-- Para iniciar a instância padrão do SQL Server com configuração mínima
sqlservr.exe -f

-- Aumetando a memória
sp_configure 'show advanced options', 1
RECONFIGURE
GO
sp_configure 'max server memory', 24000

