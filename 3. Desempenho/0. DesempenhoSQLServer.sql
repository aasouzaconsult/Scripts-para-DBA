-- Exibições e funções de gerenciamento dinâmico (Transact-SQL) - https://technet.microsoft.com/pt-br/library/ms188754.aspx

/*************************************
 ** Requisições / Tarefas de espera **
 *************************************/
-- Requisições ao SQL Server - https://technet.microsoft.com/pt-br/library/ms177648.aspx
--- Para cada pedido de execução feito ao servidor SQL Server existe uma linha registrada em sys.dm_exec_requests.

-- Tarefas de espera - https://technet.microsoft.com/pt-br/library/ms188743.aspx

-- Parallel Query Processing - https://technet.microsoft.com/en-us/library/ms178065(v=sql.105).aspx
-- - The Parallelism Operator - http://blogs.msdn.com/b/craigfr/archive/2006/10/25/the-parallelism-operator-aka-exchange.aspx

--SELECT r.session_id, 
--       status, 
--       command,
--       r.blocking_session_id,
--       r.wait_resource,
--       r.wait_type as [request_wait_type], 
--       r.wait_time as [request_wait_time],
--       t.wait_type as [task_wait_type],
--       t.wait_duration_ms as [task_wait_time*],
--       t.blocking_session_id,
--       t.resource_description,
--       obs = ' -> EXTRAS >>',
--       r.*,
--       t.*   
--  FROM      sys.dm_exec_requests r                                   -- Requisições ao SQL Server
--  LEFT JOIN sys.dm_os_waiting_tasks t on r.session_id = t.session_id -- Tarefas em espera
-- WHERE r.session_id >= 50
--   AND r.session_id <> @@spid;

-- Observação:
-- - *CXPACKET. Pedidos que mostram esse tipo de espera estão realmente mostrando que as tarefas que deveriam ter produzido dados 
-- de consumo não estão produzindo quaisquer dados (ou dados suficientes). Essas tarefas de produtores, por sua vez, podem ser suspensas, 
-- esperando outro tipo de trava/espera, e é isso que está bloqueando seu pedido, não o operador exchange.


/********************
 ** Tipo de Espera **
 ********************/

-- Limpara os contadores 
-- DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR);
-- GO

-- Status de espera agregados - https://msdn.microsoft.com/pt-br/library/ms179984.aspx
SELECT *
     , [Tempo Médio] = wait_time_ms/waiting_tasks_count --  vai dizer o tempo médio que um tipo de espera em particular tem aguardado.
  FROM sys.dm_os_wait_stats
 WHERE [wait_type] NOT IN (
        N'CLR_SEMAPHORE',    N'LAZYWRITER_SLEEP',
        N'RESOURCE_QUEUE',   N'SQLTRACE_BUFFER_FLUSH',
        N'SLEEP_TASK',       N'SLEEP_SYSTEMTASK',
        N'WAITFOR',          N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
        N'CHECKPOINT_QUEUE', N'REQUEST_FOR_DEADLOCK_SEARCH',
        N'XE_TIMER_EVENT',   N'XE_DISPATCHER_JOIN',
        N'LOGMGR_QUEUE',     N'FT_IFTS_SCHEDULER_IDLE_WAIT',
        N'BROKER_TASK_STOP', N'CLR_MANUAL_EVENT',
        N'CLR_AUTO_EVENT',   N'DISPATCHER_QUEUE_SEMAPHORE',
        N'TRACEWRITE',       N'XE_DISPATCHER_WAIT',
        N'BROKER_TO_FLUSH',  N'BROKER_EVENTHANDLER',
        N'FT_IFTSHC_MUTEX',  N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        N'DIRTY_PAGE_POLL',  N'SP_SERVER_DIAGNOSTICS_SLEEP')
   AND  waiting_tasks_count > 0
ORDER BY wait_time_ms DESC;
--ORDER BY wait_time_ms/waiting_tasks_count DESC;


-------------------------------------------
-- Disco e IO relacionado a tipos de espera
-------------------------------------------
-- PAGEIOLATCH_* (Este é o IO por excelência: os dados lidos do disco são gravados sob a forma de um tipo de espera. A tarefa bloqueada nesse tipo de espera está aguardando dados a serem transferidos entre o disco e o cache de dados em memória (o pool de buffer). Em um sistema que tem alta PAGEIOLATCH_* agregada a algum tipo de espera, é muito provável que a memória seja consumida e esteja gastando muito tempo lendo dados do disco para o buffer.)

-- WRITELOG (Esse tipo de espera ocorre quando uma tarefa emite um COMMIT e aguarda o registro ser concluído para escrever a transação no log do disco. Tempos de resposta médios e elevados nesse tipo de espera indicam que o disco está escrevendo o log lentamente, e isso diminui a cada transação. Tempos de resposta muito frequentes nesse tipo de espera são indicativos de que estão criando muitas pequenas transações e terão que ser bloqueadas com frequência para esperar pelo COMMIT (lembre-se de que tipos que escrevem todos os dados exigem uma transação separada e que é implicitamente criada para cada declaração, senão BEGIN TRANSACTION é usado explicitamente).)

-- IO_COMPLETION (Esse tipo de espera ocorre para as tarefas que estão esperando por algo mais do que os dados de IO. Por exemplo, carregar uma DLL, ler e escrever arquivos de ordenação do tempdb, ou então esperam por dados especiais referentes a operações de leitura DBCC.)

-- ASYNC_IO_COMPLETION (Esse tipo de espera é geralmente associado com backup, restauração de dados e operações com arquivos de banco de dados.Se, em sua análise, o tempo de espera constatar que o registro de IO e disco são importantes tipos de espera, então sua tarefa deve se concentrar em analisar a atividade de disco.)

-----------------------------------------
-- Tipos de espera relacionados à memória
-----------------------------------------
-- RESOURCE_SEMAPHORE (Esse tipo de espera indica as consultas que estão à espera de uma concessão de memória. Confira o documento Entenda a concessão de memória do servidor SQL. Consultas do tipo de carga de trabalho de OLTP não devem exigir grandes concessões de memória. Caso você se depare com esse tipo de espera em um sistema OLTP, reveja seu projeto de software. Cargas de trabalho OLAP muitas vezes possuem a necessidade de concessões de memória (algumas vezes grande) e grandes tempos de espera que geralmente apontam para o aumento das atualizações de memória RAM.)

-- SOS_VIRTUALMEMORY_LOW (Você ainda está convivendo com sistemas de 32 bits? Siga em frente!)

--------------------------------------
-- Tipos de espera relacionados à rede
--------------------------------------
-- ASYNC_NETWORK_IO (Esse tipo de espera indica que o SQL Server possui determinados conjuntos de resultados que devem ser enviados para o aplicativo, mas este pode não processá-los. Isso pode indicar uma conexão de rede lenta, mas não necessariamente. Mas, mais frequentemente, o problema está relacionado com o código do aplicativo, ou então com algum bloqueio ao processar o conjunto de resultados, ou ainda está solicitando um enorme conjunto de resultados que não estão sendo entregues em tempo hábil.)

-------------------------------------------------------------
-- CPU, disputa e concorrência relacionadas a tipos de espera
-------------------------------------------------------------
-- LCK_* (Locks ou travas. Todos os tipos de espera que começam com LCK indicam uma tarefa suspensa à espera de um bloqueio qualquer. 
--O tipo de espera LCK_M_S* indica uma tarefa que está esperando para ler dados (que podem ser bloqueios compartilhados) e está bloqueada 
--por outra tarefa que tinha modificado os dados (tinha adquirido uma trava LCK_MX* exclusiva). O tipo de espera LCK_M_SCH* indica bloqueio 
--de objetos relacionados à modificação de esquema e indicam que o acesso a um objeto (como uma tabela) está bloqueada por outra tarefa que 
--fez uma modificação em alguma DLL que acessa esse objeto (ALTER).)

-- PAGELATCH_* (Não confunda esse tipo de espera com o PAGEIOLATCH_*. Tempos de espera elevados para PAGELATCH_* indicam um ponto de 
--grande acesso no banco de dados, uma região de dados que são é frequentemente atualizada (que, por exemplo, poderia ser um único 
--registro em uma tabela que é constantemente modificada). Para uma análise mais aprofundada, recomendo o whitepaper Diagnosticando e 
--resolvendo disputas e travas no SQL Server. SQLServerLatchContention.pdf)

-- LATCH_* (Esses tipos de espera indicam contenção em recursos internos do SQL Server, mas não necessariamente em dados (ao contrário 
--do PAGELATCH_*, não indicam um ponto muito movimentado do servidor). Para investigar essas esperas, será preciso cavar ainda mais fundo 
--usando os sys.dm_os_latch_stats DMV que detalham os tempos de espera por tipo de trava. Mais uma vez, é uma boa ideia ler o whitepaper 
--Diagnosticando e resolvendo disputas e travas no SQL Server.)

-- CMEMTHREAD (Esse tipo de espera ocorre quando as tarefas estão bloqueadas, esperando para acessar um alocador de memória compartilhada. Coloquei esse tipo aqui, na seção de concorrência, e não na seção de “memória”, pois o problema está relacionado com a concorrência interna do SQL Server. Se você ver tipos de espera com altos valores em CMEMTHREAD, certifique-se de que você está utilizando a versão mais recente do SQL Server Service Pack disponível e também a Atualização Cumulativa para a sua versão, porque alguns desses tipos de problemas reportam questões internas do SQL Server e muitas vezes são tratados em versões mais recentes.)

-- SOS_SCHEDULER_YIELD (Esse tipo de espera pode indicar uma contenção do tipo spinlock. Spinlocks são tipos de espera extremamente leves e primitivos no SQL Server, utilizados para proteger o acesso a recursos que podem ser modificados dentro de poucas instruções de bloqueio da CPU. Tarefas do SQL Server adquirem spinlocks por fazer operações interligadas à CPU dentro de um loop, assim, a contenção em spinlocks queima um monte de tempo de CPU (contadores de uso de CPU mostram entre 90-100% de uso, mas o progresso é lento). Uma análise mais aprofundada precisa ser feita usando sys.dm_os_spinlock_stats:)
-- SELECT * FROM sys.dm_os_spinlock_stats ORDER BY spins DESC; -- http://www.microsoft.com/en-us/download/details.aspx?id=26666

-- RESOURCE_SEMAPHORE_QUERY_COMPILE (Esse tipo de espera indica que uma tarefa está esperando para compilar seu pedido. Tempos de resposta elevados para esse tipo de espera indicam que a compilação da consulta enfrenta um problema de desempenho. Para mais detalhes, recomendo a leitura do documento Resolução de problemas com cache.)
-- https://technet.microsoft.com/en-us/library/cc293620.aspx

-- SQLCLR_QUANTUM_PUNISHMENT (Esse tipo de espera ocorre se for executado código CLR dentro do motor SQL Server, e esse código CLR não ceder espaço de CPU. Isso resulta em um estrangulamento do código CLR. Se você tiver o código CLR que potencialmente poderá sequestrar o uso de CPU por um longo período, deve chamar Thread.BeginThreadAffinity(). Para mais detalhes, recomendo conferir o link Dados mais rápidos: técnicas para melhorar o desempenho do Microsoft SQL Server com SQLCLR.)

----------------------------
-- Tipos de espera especiais
----------------------------
-- TRACEWRITE (Esse tipo de espera indica que as tarefas são bloqueadas pelo SQL Profiler. Esse tipo de espera ocorre somente se você tiver o SQL Profiler conectado ao servidor e ocorre com frequência durante a investigação de problemas de desempenho, se você tiver criado um rastreamento SQL Profiler muito agressivo (que recebe muitos eventos, por exemplo).)

-- PREEMPTIVE_OS_WRITEFILEGATHER (Esse tipo de espera ocorre, entre outros motivos, quando o aumento automático dos arquivos é acionado. Técnica chamada de autocrescimento, ela ocorre quando um arquivo de tamanho insuficiente é mantido pelo SQL Server em um evento muito dispendioso para a CPU do servidor. Durante o crescimento do arquivo, toda a atividade no banco de dados estará congelada. Esse crescimento do arquivo de dados pode ser feito rapidamente, permitindo o crescimento do arquivo instantâneos – consulte Arquivo de inicialização de banco de dados para mais informações. Mas o crescimento do log não pode se beneficiar da inicialização instantânea de arquivo de log, porque o crescimento é sempre lento, e às vezes muito lento. Registrar eventos de autocrescimento pode ser diagnosticado simplesmente olhando para o contador de desempenho no log (confira o link banco de dados de objetos SQL Server para mais informações), onde 0 significa que o log registrou o autocrescimento pelo menos uma vez. O monitoramento em tempo real pode ser feito observando o arquivo de dados de autocrescimento e o log de autocrescimento de arquivos no SQL Profiler.)

----------------------------------------
-- Tipos de Wait Types (Tipos de espera)
----------------------------------------
-- Ver planilha: WaitTypes_Descrição.xls

-- (OUTRA FORMA DE OBTER ESSES DADOS)Wait statistics, or please tell me where it hurts 
-- http://www.sqlskills.com/blogs/paul/wait-statistics-or-please-tell-me-where-it-hurts/


/*******************************************************
 ** Analisar a atividade do disco: estatísticas de IO **
 *******************************************************/
  
select db_name(io.database_id) as database_name,
    mf.physical_name as file_name,
    io.* 
from sys.dm_io_virtual_file_stats(NULL, NULL) io
join sys.master_files mf on mf.database_id = io.database_id 
    and mf.file_id = io.file_id
order by (io.num_of_bytes_read + io.num_of_bytes_written) desc;


-- SET STATISTICS TIME ON

-- SET STATISTICS IO ON
-- - verificação de contagem (Número de vezes em que os exames ou a busca foram iniciados em uma tabela. Idealmente, cada tabela deve ser verificada no máximo uma vez.)
-- - leituras lógicas (Número de páginas de dados a partir do qual as linhas foram lidas a partir do cache de memória (pool de buffer).)
-- - leituras físicas (Número de páginas de dados a partir do qual os dados foram ou tiveram de ser transferidos do cache na memória (área de buffer) e a tarefa teve que bloquear para esperar que a transferência terminasse.)
-- - read-ahead (Número de páginas de dados que foram transferidas de forma assíncrona do disco para o pool do buffer e cuja tarefa não esperou nenhum dado para a transferência.)
-- - LOB lógico/físico (O mesmo que suas contrapartes não-LOB, mas referindo-se à leitura de grandes colunas de dados (LOBs).)


/************************************************************************
 ** Analisando o tempo de espera e a execução de consultas individuais **
 ************************************************************************/
-- Ver: 01. AnaliseConsulta_WAIT.sql


/*****************************************************************
 ** Analise de Desempenho utilizando o SQL Server e Ferramentas **
 *****************************************************************
 
-- Pontos a serem analisados:
1. CPU - Processamento
2. Memória
3. I/O - Entrada e Saída
4. Banco de Dados TempDB
5. Lentidão na execução de Querys

***** Detecção de Problemas *****
1. Identificar Bottleneck ("Gargalo") - Maior fator que afeta a perfomance
2. Por onde começar? Defina sempre problema
	2.1 Qual seu "baseline"?
		- Planilha com informações dos problemas que mais apresenta no sistema
	2.2 Aconteceu alguma alteração no sistema
		- Algum software ou Service Pack novo instalado
3. Atenção ao limite do seu sistema
	3.1 Trabalhar proximo da capacidade máxima X Uso ineficiente de recursos

***** Questionamentos *****
1. Existe algum outro recurso do sistema que será afetado?
2. Quais os possiveis passos para solucionar o problema?
- Documentação é interessante
3. Foi realizada alguma alteração que possa ter causado o problema?	
- Criação de Stored Procedures e etc
- Documentação é interessante

##########################
# 1. CPU - Processamento #
##########################
***** Ferramentas utilizadas *****
- System Monitor (Microsoft Windows Server 2003 / 2008)
	- Processor object
		- % Processor Time Counter > 80% (Sinal que CPU é o Gargalo)
	- SQL Statistics
		- Batch Request/sec
		- SQL Compilations/sec
		- SQL Re-Compilations/sec (Ideal: Baixas taxas de recompilação nas requisições)
- Task Manager
	- Performance > CPU Usage
- SQL Server (View DMV's) */
	Select * From sys.dm_os_schedulers
		-- Tarefas que estão na fila para serem executadas
		-- Identificar se o campo runnable_tasks_count esta alto
	Select * From sys.dm_exec_query_stats
		-- Estatisticas de Plano de Query
		-- Estatisticas do Plano de Cache - (Campos: total_worker_time, execution_count)

/* ***** Causa de Problemas: CPU *****
1. Compilação e/ou recompilação excessiva:
	- Problemas:
		- WITH RECOMPILE nas StoredProcedure
	- Ferramentas: 
		- System Monitor > SQL Statistics
		- SQL Trace (SP:Recompile;SQL:StmtRecompile)
	- Objetivo: Identificar e reduzir
	- Soluções:
		- Considere utilizar tabelas temporárias e/ou variavel Table
		- Atualização de estatisticas automaticas (on / off)
		- Use nome de objetos qualificados (dbo.TableA X TableA)
		- Não misture comandos DDL e DML.
		- Use DTA (Database Engine Tuning Advisor) 
			- http://www.microsoft.com/technet/prodtechnol/sql/2005/sql2005dta.mspx
			- identificar indices não utilizados ou necessidade de criação de indices.
		- Considere a real necessidade de utilizar WITH RECOMPILE em Stored Procedures

2. Plano de Query ineficiente
	- Ferramentas:
		- DMV's */
			Select * From sys.dm_exec_query_stats
			Select * From sys.dm_exec_sql_text -- Diagnosticar CPU  
			-- Procuram por Querys que fazem uso itensivo de CPU
			Select * From sys.dm_exec_cached_plans -- Procura por operadores que fazem uso da CPU 
			/*
	- Objetivo: 
		- Coletar informações para escrever query com planos mais eficientes 
	- Soluções:
		- Use DTA para checar recomendações de indices
		- Use de forma restritiva a clausula WHERE
			- Causa problemas em relação a CPU
		- Mantenha as estatisticas atualizadas
		- Procure por Query que não foram escritas seguindo boas praticas de desenvolvimento
		- Considere utilizar "Query hints"
			- OPTIMIZE FOR - valor de parametro particular para otimização
			- FORCE ORDER - preserva a ordem dos joins
			- USE PLAN - força o Plano de Query

3. Paralelismo "Intra-query"
	- Problema:
		Querys utilizando paralelismo tem um custo alto para a CPU
	- Ferramentas:
		- DMV's */
			Select * From sys.dm_exec_requests
			Select * From sys.dm_os_tasks
			Select * From sys.dm_exec_sessions
			Select * From sys.dm_exec_sql_text
			Select * From sys.dm_exec_query_stats --Campos: total_worker_time e total_elapsed_time
			/*			
	- Objetivo: Identificar querys rodando com paralelismo e torna-las mais eficientes.
	- Soluções:
		- Use DTA
		- Mantenha as estatisticas atualizadas
		- Procure por estatisticas desatualizadas
		- Avalie se a query pode ser reescrita de forma mais eficiente utilizando o T-SQL.

$$$$$ Demonstração CPU $$$$$ */	
---------------------------------------------------------
-- 1. Retorna as 10 Querys com maior tempo de execução --
---------------------------------------------------------
Select  Top 10
		creation_time
,		last_execution_time
,		total_clr_time
,		total_clr_time / execution_count as [Avg CLR Time]
,		last_clr_time
,		execution_count
,		Substring (st.text, (qs.statement_start_offset / 2) + 1,
		((Case statement_end_offset
			when -1 then datalength(st.text)
			else qs.statement_end_offset 
			end -qs.statement_start_offset)/2) + 1) as Query
From	sys.dm_exec_query_stats as qs
cross apply sys.dm_exec_sql_text(qs.sql_handle) as st
Order by
		total_clr_time / execution_count desc

-----------------------------------------------------------------------
-- 2. Retorna a Média das 5 Query's que mais consumiram tempo de CPU --
-----------------------------------------------------------------------
Select Top 10
		total_worker_time / execution_count as [Avg CPU Time]
,		Substring (st.text, (qs.statement_start_offset / 2) + 1,
		((Case statement_end_offset
			when -1 then datalength(st.text)
			else qs.statement_end_offset 
			end	-qs.statement_start_offset)/2) + 1) as Query		
From	sys.dm_exec_query_stats as qs
cross apply sys.dm_exec_sql_text(qs.sql_handle) as st
Order by
		total_worker_time / execution_count desc	

/*############
# 2. Memória #
##############
- Problemas:
	- Erros explícitos relacionados a memória (ex. "Out of memory", "timeout" enquanto aguarda
    por recursos de mémoria livre)
	- Valor baixo de "buffer cache hit ratio"
	- Utilização incomum e excessiva de I/O
	- Lentidão no sistema de uma forma geral
- Erros relacionados(Mensagens):*/
	Select * from sys.messages 
	Where	message_id in (701, 802, 8628, 8645, 8651)
	and		language_id = 1033 --Inglês
	/*
- Ferramentas: (Detecção e Análise)
	- Task Manager
		- Mem Usage, Virtual Machine Size
		- Physical Memory, Commit charge (Uso do Page File)
			- Ideal: Page File Fixo
	- System Monitor
		- Performance object: Process
			- Counters: Working set, Private bytes
		- Performance object: Memory 
			- Counters: Avaliable KBytes, System Cache, Resident Bytes, Committed bytes, Commit Limit
		- Performance object: SQLServer: Buffer Manager
			- Counters: Buffer cache hit ratio, Page file expectancy, Checkpoint pages/sec, Lazy writes/sec
		- Performance object: SQLServer: Memory Manager
	- DM'V's: */
		Select * From sys.dm_os_memory_clerks
			-- Trabalhadores ativos de memória (por instância)
		Select * From sys.dm_os_memory_cache_clock_hands
			-- Status de ponteiro para cache especifico
		Select * From sys.dm_os_memory_cache_counters
			-- Snapshot (Estado do Cache), endereço de entrada do cache
		Select * From sys.dm_os_ring_buffers
			-- Alterações no estado da memória
		Select * From sys.dm_os_virtual_address_dump /*
	- DBCC */
		dbcc memorystatus /*
			- Buffer distribution
			- Buffer counts
			- Global memory objects
			- Query memory object
			- gateways
- Objetivo:
	- Analisar consumo de memória
- Soluções:
	- Verifique parâmetros de configuração de memória no servidor (Configurações inconsistentes)
		- Min memory per query 
		- Min/Max server memory
		- Awe enable
		- Lock pages em memória privilegiada
	- Realize sucessivas coletas de informações utilizando DMV's e DBCC memorystatus e dos contadores
	de performance do System Monitor (Compare com sua "BaseLine")
	- Confira a carga de trabalho (Número de Queries/sessions)
	- Entenda a razão do aumento de consumo de memória e tente sempre que possivel elimina-las.
		- Muitas vezes não será possivel, ai cabe analisar se vai ser necessário adição de + memória.

$$$$$ Demonstração MEMÓRIA $$$$$ */
	Select * From sys.dm_os_memory_cache_counters -- Exemplo 1 > Detalhes mais acima
	dbcc memorystatus -- Exemplo 2 > Detalhes mais acima
	Select * From sys.dm_os_memory_clerks -- Exemplo 3 > Detalhes mais acima 

/*###########################
# 3. I/O - Entrada e Saída #
############################
- Problemas(Vilões):
	- Movimentação de páginas do banco de dados da memória para o disco e vice-versa
	- Operações dos arquivos de Log
	- Operações no Banco de Dados TempDB
- Sinais de Problemas:
	- Tempo de resposta baixo
	- Mensagem com erros de "timeout"
	- O sistema de I/O operando em sua capacidade máxima
- Objetivo:
	- Identificar "gargalos" no I/O
- Fases de Detecção / Ferramentas:
	- System Monitor (Performande Monitor)
		- % Disk Time > 50% (Problema)
		- Avg. Disk Queue Length > 2 (Problema Grave)
		- Avg. Disk sec/Read ou Avg. Disk sec/Write 
			- < 10ms (Muito Bom)
			- > 10 e <= 20ms (Bom)
			- > 20 e <= 50ms (Atenção Especial)
			- > 50ms (Grave - Gargalo no I/O)
		- Avg. Disk Reads/sec ou Avg. Disk Writes/sec > 85% da capacidade do disco
			- Problema Grave
			- Ajustes para RAID:
				- RAID 0  : I/Os per disk = (reads + writes) / numero de discos
				- RAID 1  : I/Os per disk = [reads + (2 * writes)] / 2
				- RAID 5  : I/Os per disk = [reads + (4 * writes)] / numero de discos
				- RAID 1+0: I/Os per disk = [reads + (2 * writes)] / numero de discos
	- DMV's: */
		Select * From sys.dm_os_wait_stats where wait_type like 'PAGEIOLATCH%'
			-- Tempo gasto na fila (Ficaram na fila)
		Select * From sys.dm_io_pending_io_requests
			-- 1 Linha para cada requisição de I/O pendente
		Select * From sys.dm_exec_query_stats
			-- *_reads
			-- *_writes columns
		/*
- Solução / Análise:	
	- Certifique-se que esta usando ótimos planos de query
		- Possibilidade de reescrever em caso de planos de query não eficientes
	- Alto I/O pode indicar "Gargalo" na memória
	- Confira a quantidade de memória e analise a possibilidade de adição.
	- Aumente a largura de banda do I/O
		- Discos rápidos
		- Controladoras	com mais cache (Em sincronia com os discos)
	- Esteja sempre atento a capacidade do seu sistema	
	
$$$$$ Demonstração I/O $$$$$ */
	Select * From sys.dm_os_wait_stats where wait_type like 'PAGEIOLATCH%'`
		-- Exemplo 1 > [Tempo gasto na fila (Ficaram na fila)]
	Select * From sys.dm_io_virtual_file_stats (DB_ID(N'AdventureWorks'), 1) 
		-- 1 é para arquivos de Dados (Informações de Escrita e Leitura)
	Select * From sys.dm_io_virtual_file_stats (DB_ID(N'AdventureWorks'), 2)
		-- 2 é para arquivos de Log (Informações de Escrita e Leitura)

/*##########################
# 4. Banco de Dados TempDB #
############################
- Utilização:
	- Armazenamento de tabelas temporárias (#Locais e/ou ##Globais)
	- SQL Server utiliza para criar objetos internos
	- Tem o seu conteúdo eliminado quando o serviço do SQL Server é parado
		- Recriado novamente ao iniciar o serviço 
- Problema:
	- Procedimentos sendo executados fora do TempDB
	- "Gargalos" nas "System Tables" devido as excessivas operações de DDL
- Objetivo:
	- Monitorar o uso excessivo de DDL, procurar e, se possível, 
	eliminar "procedimentos intrusos" no TempDB.
- Ferramentas:
	- DMV's: */
		Select * From sys.dm_db_file_space_usage
			-- Retorna informações de espaço utilizado por cada arquivo no Database
			-- Usuarios, Objetos internos e Espaço utilizado
		Select * From sys.dm_tran_active_snapshot_database_transactions
			-- Transações que rodam lentamente > Maior Espaço
			-- Retorna todas as transações ativas no TempDB
		Select * From sys.dm_db_session_space_usage
			-- Número de páginas alocadas ou não alocadas para cada sessão do Database
		Select * From sys.dm_db_task_space_usage 
			-- Retorna atividades de Alocação e Desalocação das tarefas do Database
		/*
	- System Monitor(PerfMon):
		- SQL Server: Transactions Object
			- Version Generation / Cleanup rates
- Solução:
	- Faça um plano de capacidade para o TempDB
		- Contabilize os procedimentos que utilizam o TempDB
		- Reserve espaço suficente para o TempDB
	- Objetos "User": Identifique e elimine usuários desnecessários no TempDB
	- Cuidados com o tamanho do TempDB
		- Elimine longas transações sempre que possível
 	- Excessivos DDL:
		- Considere quando criar tabelas temporárias (Locais e/ou Globais)
		- Considere os planos de query que criam diversos objetos internos e verifique se
		estão escritos de forma eficiente ou se será preciso descreve-los.	
	
##########
# Extras # 
##########
---- Script com tarefas em tempo real no TempDB */
Select 
		t1.session_id
,		(t1.internal_objects_alloc_page_count + task_alloc) as allocated
,		(t1.internal_objects_dealloc_page_count + task_dealloc) as deallocated 
From	sys.dm_db_session_space_usage as t1
,		(Select 
				session_id
		,		sum(internal_objects_alloc_page_count) as task_alloc
		,		sum (internal_objects_dealloc_page_count) as task_dealloc 
		From	sys.dm_db_task_space_usage 
		Group by 
				session_id) as t2
Where 
		t1.session_id = t2.session_id and t2.session_id > 50
order by 
		allocated DESC

-- Para otimização (Estudar)
Select * From	sys.dm_exec_query_optimizer_info
Where	counter in ( 
	'optimizations'
,	'elapsed time'
,	'trivial plan'
,	'tables'
,	'insert stmt'
,	'update stmt'
,	'delete stmt')


-- Auxiliares
Select @@TRANCOUNT -- Transações da sessão corrente

------------------
-- Bibliografia --
------------------
--http://msdn.microsoft.com/pt-br/library/bb510669.aspx (Performance)