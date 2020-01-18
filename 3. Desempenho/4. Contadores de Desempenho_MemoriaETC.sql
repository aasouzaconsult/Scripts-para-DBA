/******************************
 ** Contadores de Desempenho **
 ******************************/
--select * from sys.dm_os_performance_counters

-- Montando...                                                                                                     
Select	A = Convert(decimal (19,5), (  ( SELECT convert(decimal(19,8), cntr_value) FROM sys.dm_os_performance_counters WHERE object_name = 'SQLServer:Buffer Manager' AND counter_name = 'Buffer cache hit ratio')
									 / ( SELECT convert(decimal(19,8), cntr_value) FROM sys.dm_os_performance_counters WHERE object_name = 'SQLServer:Buffer Manager' AND counter_name = 'Buffer cache hit ratio base'))) * 100
,		B = ( SELECT cntr_value AS 'Page Life Expectancy - Ideal > 300' FROM sys.dm_os_performance_counters
			  WHERE object_name = 'SQLServer:Buffer Manager' AND counter_name = 'Page life expectancy') 

-- A = Buffer cache hit ratio - Ideal > 99
-- B = Page Life Expectancy - Ideal > 300

/***************************
 ** Contadores de MEMÓRIA **
 ***************************/
-- Memória do Servidor
Select	counter_name 
,		cntr_value
,		cast((cntr_value/1024.0) as numeric(8,2)) as Mb
,		cast((cntr_value/1024.0)/1024.0 as numeric(8,2)) as Gb
From sys.dm_os_performance_counters
Where counter_name like '%server_memory%';

-- Memória: Alocada em Cache por Banco de Dados
SELECT	DB_NAME(database_id) AS [Database Name]
,		COUNT(*) * 8/1024.0 AS [Cached Size (MB)]
,		SUM (CAST ([free_space_in_bytes] AS BIGINT)) / (1024 * 1024) AS [Cached Size (MB) - Empty]
FROM	sys.dm_os_buffer_descriptors
WHERE	database_id > 4		 -- exclude system databases
AND		database_id <> 32767 -- exclude ResourceDB
GROUP BY 
		DB_NAME(database_id)
ORDER BY
		[Cached Size (MB)] DESC


-- Memória: Utilização por tipo de cache
SELECT  type, SUM(single_pages_kb)/1024. AS [SPA Mem, MB],SUM(Multi_pages_kb)/1024. AS [MPA Mem,MB]
FROM sys.dm_os_memory_clerks
GROUP BY type
HAVING  SUM(single_pages_kb) + sum(Multi_pages_kb)  > 40000 -- Só os maiores consumidores de memória
ORDER BY SUM(single_pages_kb) DESC

-- O CACHESTTORE_OBJCP  é o cache das Stored procedures, Triggers e Functions.
-- O CACHESTORE_SQLCP é o cache de Ad-hoc queries e não é muito reutilizado pelo SQL Server, pois para uma mesma consulta com parâmetros diferentes, são gerados dois planos de execuções diferentes.
-- O USERSTORE_TOKENOERM é o cache que armazena várias informações de segurança que são utilizadas pela Engine do SQL Server.

-- Memória: Total utilizado
SELECT  SUM(single_pages_kb)/1024. AS [SPA Mem, MB],SUM(Multi_pages_kb)/1024. AS [MPA Mem, MB]
FROM sys.dm_os_memory_clerks


/*************************
 ** Performance Monitor **
 *************************

 *************************************
 * Objeto: SQL Server:Buffer Manager *
 *************************************
 (Está relacionado a instância SQL Server, cada instância SQL Server terá objetos próprios)
    - Buffer Cache Hit Ratio: indica o percentual de páginas de foram atendidas pelo buffer pool. O ideal é que este 
valor seja igual ou superior a 99%. Valores inferiores podem indicar memória insuficiente para a instância SQL Server.
		- Ideal: > 90%
		- Ruim.: < 90%

    - Checkpoints Page/sec: indica o número de páginas limpas no disco por segundo. O valor ideal é abaixo de 50. Se este valor 
estiver constantemente alto, pode indicar que a instância SQL Server precisa de mais memória.
		- Ideal: < 50
		- Ruim.: > 50 (Constantemente)

    - Lazy writes/sec: indica o número de vezes por segundo que o lazy write elimina as páginas do buffer cache. Se este valor 
estiver maior que 20, pode indicar que a instância SQL Server precisa de mais memória.
		- Ideal: < 20
		- Ruim.: > 20

    - Page life expectancy: indica a expectativa de vida (em segundos) de uma página de dados na memória. O ideal é que este 
valor seja sempre superior a 300 segundos. Valores inferiores podem indicar necessidade de memória para a instância SQL Server.
		- Ideal: > 300 seg
		- Ruim.: < 300 seg

    - Target Pages:  indica o número ideal de páginas no buffer pool.

    - Total Pages: indica o número de páginas que estão no buffer pool no momento.  Este valor deve ser menor 
o valor do contador Target Pages.
		- Ideal: < Target Pages
		
	- Page reads/sec (80 a 90)
	
	- Page Writes/sec (80 a 90)

 *************************************
 * Objeto: SQL Server:Access Methods *
 *************************************
	- Page Splits/sec: Mostra quantos page splits estão ocorrendo no servidor. Este valor deve ser o mais baixo possível. Se o valor estiver alto,
configurar os índices com um fillfactor apropriado pode ajudar a reduzir este valor.
		- Ideal: Sempre baixo

	- Full Scans/sec
	
 *************************************
 * Objeto: SQL Server:Memory Manager *
 *************************************
 (Está relacionado a instância SQL Server) 
	- Memory Grants Pending: indica o número de processos esperando na área de trabalho da memória. O ideal é este valor fique 
próximo de zero. Caso os valores sejam constantemente altos, deve-se certifica-se de que o problema está relacionado a 
insuficiencia de memória e não a objetos dos bancos de dados.
		- Ideal: 0 (Próximo a 0)
		- Ruim.: Valores constantemente altos

    - Target Server Memory: indica o total de memória que a instância SQL Server pode utilizar.

    - Total Server Memory: indica o total de memória que a instância SQL Server está utilizando no momento. Se este valor for 
igual ou maior que o valor do Target Server Memory, pode indicar a necessidade de mais memória para a instância SQL Server. 
		- Ideal: < Target Server Memory
		- Ruim: >= Target Server Memory
 
 *******************
 * Objeto: Process *
 *******************
 (Relacionado ao servidor que hospeda a  instância SQL Server)
	- Working Set: indica o tamanho do conjunto da carga de trabalho dos processos em bytes na memória física do servidor. 
Caso este valor permaneça sempre abaixo do mínimo de memória configurada para instância SQL Server, isso indica que a instância 
está configurada com mais memória do que realmente precisa.
		- Ideal: > Mínimo de Memória configurada para a instancia
		- Ruim: < Mínimo de Memória configurada para a instancia
	
	- % Processor time: sqlservr ==> Indica o consumo do processador pelo processo do SQL Server.
		- Ideal : < 80%
	
	- Processo Queue Length ( < 2 )

 *******************************
 * Objeto: Disco (LogicalDisk) *
 *******************************
	- Avg disk sec/read (Ideal: < 12ms)
	- Avg disk sec/write (Ideal: < 12ms)
	
 ****************
 * Objeto: Rede *
 ****************
	- Bytes Received/sec
	- Bytes Sent/sec
 
 ******************
 * Objeto: Memory *
 ******************
	- Available Mbytes: indica a quantidade de memória disponível em MB no momento. O ideal é que este 
contador esteja com valor acima de 100 MB. Valores inferiores podem indicar a necessidade de mais memória RAM.
		- Ideal: > 100MB
		- Ruim.: < 100 MB		
		
    - Pages/sec: indica o número de páginas que são páginadas na memória para o disco por segundo. O ideal é 
que este a média deste contador esteja sempre próximo de zero  em um intervalo de 24 horas e em situações 
normais. Picos ocasionais podem aumentar este valor. Se a média do contador for maior que 20, o servidor 
precisará de mais memória RAM. 
		- Ideal: 0 (Média proximo a 0)
		- Ruim.: > 20 (Média)
		
	- Pages faults/sec
	
 ******************************************
 * Objeto: System: Processor Queue Length *
 ******************************************
	- Indica o número de threads aguardando para execução no processador e nunca deve exceder 1 ou 2 (por processador) por 
um período superior a 10 minutos.


-- Fontes:
-- http://tatianecosvieira.wordpress.com/2011/08/03/artigo-performance-no-sql-server-%E2%80%93-memoria-parte-1/
-- http://dicasdeumdba.wordpress.com/tag/perfmon/

*/