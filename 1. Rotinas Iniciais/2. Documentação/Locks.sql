---- Armazem de locks
--SELECT *
--  FROM AnaliseInstancia..MonitoraLocks
-- ORDER BY data_hora DESC

-- S - Usado para operações de leitura que não alteram ou atualizam dados, como uma instrução SELECT.
-- U - Usado em recursos que podem ser atualizados. Evita uma forma comum de deadlock que ocorre quando várias sessões estão lendo bloqueando e potencialmente atualizando recursos mais tarde.
-- X - Usado para operações da modificação de dados, como INSERT, UPDATE ou DELETE. Assegura que várias atualizações não sejam realizadas no mesmo recurso e ao mesmo tempo.
-- IS, IX, SIX - Usado para estabelecer uma hierarquia de bloqueio. Os tipos de bloqueios intencionais são: tentativa compartilhada (IS), exclusivo de tentativa (IX) e compartilhado com exclusivo de tentativa (SIX).
-- Sch-M, Sch-S - Usado quando uma operação dependente do esquema de uma tabela está executando. Os tipos de bloqueios de esquema são: modificação de esquema (Sch-M) e estabilidade de esquema (Sch-S).
-- BU - Usado quando para copiar dados em massa em uma tabela e a dica TABLOCK está especificada.

-- http://msdn.microsoft.com/pt-br/library/ms190615%28v=sql.105%29.aspx -- Bloqueios no mecanismo de banco de dados
-- http://msdn.microsoft.com/pt-br/library/ms186396%28v=sql.105%29.aspx -- Compatibilidade de bloqueios
-- http://msdn.microsoft.com/pt-br/library/ms175519%28v=sql.105%29.aspx -- Modos de Bloqueio
-- http://msdn.microsoft.com/pt-br/library/ms190345%28v=sql.105%29.aspx -- sys.dm_tran_locks
-- http://msdn.microsoft.com/pt-br/library/ms191242%28v=sql.105%29.aspx -- Minimizando deadlocks

-- Quantidade de Locks por dia
SELECT DATA      = Convert(VARCHAR, data_hora, 103)
     , Qtd_Locks = COUNT(*) 
  FROM AnaliseInstancia..MonitoraLocks
 GROUP BY Convert(VARCHAR, data_hora, 103)
 ORDER BY Convert(VARCHAR, data_hora, 103)
 
 -- Quantidade de Locks por dia e hora
SELECT DATA      = Convert(VARCHAR, data_hora, 103)
     , HORA      = DATEPART(HOUR, data_hora)
     , Qtd_Locks = COUNT(*)
  FROM AnaliseInstancia..MonitoraLocks
 GROUP BY CONVERT(VARCHAR, data_hora, 103)
        , DATEPART(HOUR, data_hora)
 ORDER BY CONVERT(VARCHAR, data_hora, 103)
        , DATEPART(HOUR, data_hora)
        
 -- Tipo de Bloqueio
 SELECT bloqueador_ResourceType
      , qtd = COUNT(*)
  FROM AnaliseInstancia..MonitoraLocks
 GROUP BY bloqueador_ResourceType
 ORDER BY bloqueador_ResourceType
 
 -- Quantidade por hora (total)
 SELECT HORA      = DATEPART(HOUR, data_hora)
      , QTD       = COUNT(*) / 8
  FROM AnaliseInstancia..MonitoraLocks
 GROUP BY DATEPART(HOUR, data_hora)
 ORDER BY DATEPART(HOUR, data_hora)
        
--SELECT *
--  FROM AnaliseInstancia..MonitoraLocks
-- WHERE Convert(varchar, data_hora, 112) = '20121127'
-- ORDER BY data_hora DESC
        
---- Comando bloqueadores com maior ocorrência
---- obs.: podem existir comandos identicos, mas com parametros diferentes
--SELECT Comando = sql_bloqueador
--,      Qtd     = COUNT(*)
--  FROM AnaliseInstancia..MonitoraLocks
-- GROUP BY sql_bloqueador
-- ORDER BY COUNT(*) DESC

--------------
-- AMBIENTE --
--------------
--CREATE TABLE MonitoraLocks (
--  tempo_ms int
--, data_hora Smalldatetime
--, processo int
--, sql_processo varchar(max)
--, processo_ResourceType varchar(max)
--, processo_RequestMode varchar(max)
--, bloqueador int
--, sql_bloqueador varchar(max)
--, bloqueador_ResourceType varchar(max)
--, bloqueador_RequestMode varchar(max)
--)