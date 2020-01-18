-- Conexões ativas
SELECT ConexoesAtivas = COUNT(*) FROM sys.dm_exec_connections
-- 396, 442, 401
 
-- Sessões ativas
SELECT SessoesAtivas = COUNT(*) FROM sys.dm_exec_sessions
-- 374, 422, 400
 
-- Requisições solicitadas
SELECT RequisiCOUNT(*) FROM sys.dm_exec_requests
-- 33, 36, 36