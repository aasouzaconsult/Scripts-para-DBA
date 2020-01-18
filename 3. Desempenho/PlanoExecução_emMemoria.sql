-- Planos de Execução em Memória
--http://leka.com.br/2011/11/02/quais-planos-de-execuo-esto-na-memria/
SELECT TOP 6
LEFT([name], 20) as [NOME],
LEFT([TYPE], 20) as [TIPO],
[single_pages_kb] + [multi_pages_kb] as [cache_kb],
[entries_count]
FROM sys.dm_os_memory_cache_counters
order by single_pages_kb + multi_pages_kb DESC