--ALTER DATABASE TopManager SET READ_COMMITTED_SNAPSHOT OFF WITH ROLLBACK IMMEDIATE

Select * From sys.databases

-- Muda o nível de isolamento
--SET TRANSACTION ISOLATION LEVEL READ COMMITTED

-- Habilita o nível de isolamento para Read Committed Snapshot
--ALTER DATABASE Concorrencia SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE

-- Desativa o nível de isolamento de Read Committed Snapshot
--ALTER DATABASE Concorrencia SET READ_COMMITTED_SNAPSHOT OFF WITH ROLLBACK IMMEDIATE

-- is_read_committed_snapshot_on
-- Opções:
-- 1 = A opção READ_COMMITTED_SNAPSHOT está ON. Operações de leitura sob o nível de isolamento confirmado por leitura são baseados em varreduras de instantâneo e não adquirem bloqueios.
-- 0 = A opção de READ_COMMITTED_SNAPSHOT está OFF (padrão). Operações de leitura sob o nível de isolamento confirmado por leitura usam bloqueios de compartilhamento. 

--http://msdn.microsoft.com/pt-br/library/ms173763.aspx