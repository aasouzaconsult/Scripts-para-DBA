------------------------------------------------------------------------
-- Analisando o tempo de espera e a execução de consultas individuais --
------------------------------------------------------------------------
/* Se for necessário aprofundar-se ainda mais em detalhes relacionados ao tempo de execução e às estatísticas de IO para uma 
consulta ou um procedimento armazenado, a melhor informação são os tipos de espera e tempos de espera que ocorreram durante a 
execução. A obtenção dessa informação já não é simples, mas envolve o uso estendido de eventos de monitoramento. O método que 
estou apresentando neste artigo é baseado nos tempos de resposta lentos de debug do SQL Server 2008. Ele envolve a criação de 
uma sessão de evento estendido que captura a informação sqlos.wait_info e filtra a sessão de eventos estendida para uma sessão 
de execução específica (SPID):

- links
uso estendido de eventos de monitoramento - https://technet.microsoft.com/en-us/library/bb630354(v=sql.105).aspx
tempos de resposta lentos de debug do SQL Server 2008 - http://blogs.technet.com/b/sqlos/archive/2008/07/18/debugging-slow-response-times-in-sql-server-2008.aspx

*/

-- Script
-- SET STATISTICS TIME ON
-- SET STATISTICS IO ON

create event session session_waits on server
add event sqlos.wait_info
(WHERE sqlserver.session_id=<execution_spid_here> and duration>0) -- INFORMAR O ID da Sessão que deseja analisar
, add event sqlos.wait_info_external
(WHERE sqlserver.session_id=<execution_spid_here> and duration>0) -- INFORMAR O ID da Sessão que deseja analisar
add target package0.asynchronous_file_target
      (SET filename=N'c:\temp\wait_stats.xel', metadatafile=N'c:\temp\wait_stats.xem');
go
 
alter event session session_waits on server state= start;
go

/* Com a sessão de eventos estendidos criada e iniciada, agora será possível executar a consulta ou O procedimento que deseja 
analisar. Depois disso, pare a sessão de eventos estendida e verifique os dados capturados: */
alter event session session_waits on server state= stop;
go

with x as (
select cast(event_data as xml) as xevent
from sys.fn_xe_file_target_read_file
      ('c:\temp\wait_stats*.xel', 'c:\temp\wait_stats*.xem', null, null))
select * from x;
go

-- Você pode analisar o XML em colunas para uma melhor visualização:
with x as (
select cast(event_data as xml) as xevent
from sys.fn_xe_file_target_read_file
      ('c:\temp\wait_stats*.xel', 'c:\temp\wait_stats*.xem', null, null))
select xevent.value(N'(/event/data[@name="wait_type"]/text)[1]', 'sysname') as wait_type,
    xevent.value(N'(/event/data[@name="duration"]/value)[1]', 'int') as duration,
    xevent.value(N'(/event/data[@name="signal_duration"]/value)[1]', 'int') as signal_duration
 from x;
 
-- Finalmente, podemos agregar todos os dados capturados na sessão de eventos estendidos:
with x as (
select cast(event_data as xml) as xevent
from sys.fn_xe_file_target_read_file
      ('c:\temp\wait_stats*.xel', 'c:\temp\wait_stats*.xem', null, null)),
s as (select xevent.value(N'(/event/data[@name="wait_type"]/text)[1]', 'sysname') as wait_type,
    xevent.value(N'(/event/data[@name="duration"]/value)[1]', 'int') as duration,
    xevent.value(N'(/event/data[@name="signal_duration"]/value)[1]', 'int') as signal_duration
 from x)
 select wait_type, 
    count(*) as count_waits, 
    sum(duration) as total__duration,
    sum(signal_duration) as total_signal_duration,
    max(duration) as max_duration,
    max(signal_duration) as max_signal_duration
from s
group by wait_type
order by sum(duration) desc;

-- Será exibida uma excepcional riqueza de informações sobre o que aconteceu durante a execução de um determinado pedido.



/************************
 ** TEMPO DE CONSULTAS **
 ************************/
 
--SELECT st.text,
--       pl.query_plan,
--       qs.*
--  FROM       sys.dm_exec_query_stats qs
-- cross apply sys.dm_exec_sql_text(qs.sql_handle) as st
-- cross apply sys.dm_exec_query_plan(qs.plan_handle) as pl;

-- Se você não sabe qual tipo de consulta deve procurar, para começar, o meu conselho é concentrar-se na seguinte ordem:
-- 1. Contagem de alto tempo de execução: identificar quais consultas são executadas, na maioria das vezes é, na minha opinião, mais importante do que identificar quais consultas são particularmente lentas. Na maioria das vezes, as consultas encontradas em uma fila de execução são uma surpresa e simplesmente limitam o rendimento que a contagem do tempo de execução ajudaria a ganhar em termos de desempenho.
-- 2. Grandes leituras lógicas: grandes varreduras de dados são o culpado habitual para a maioria dos problemas de desempenho do servidor SQL. Essas grandes varreduras podem ser causadas por índices perdidos, por um modelo de dados mal projetado, por planos de execução mal planejados, por estatísticas desatualizadas, por parâmetros não utilizados e várias outras causas.
-- 3. Tempo decorrido alto com baixa carga de trabalho: consultas de bloqueio não custam muito ao servidor, mas os usuários do aplicativo não se importam se o tempo em que esperam os resultados na frente da tela do computador foi gasto pelo servidor ativo ou bloqueado.