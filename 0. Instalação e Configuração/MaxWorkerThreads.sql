/*
-------------------------------------------------------------------------
Opção max worker threads
http://msdn.microsoft.com/pt-br/library/ms187024%28v=sql.105%29.aspx

-------------------------------------------------------------------------
Configurar a opção max worker threads de configuração de servidor
http://msdn.microsoft.com/pt-br/library/ms190219.aspx

-------------------------------------------------------------------------
sys.dm_os_sys_info (Transact-SQL)
http://msdn.microsoft.com/pt-br/library/ms175048.aspx

select max_workers_count, * From sys.dm_os_sys_info

-------------------------------------------------------------------------
sys.dm_os_threads (Transact-SQL)
http://technet.microsoft.com/pt-br/library/ms187818%28v=sql.105%29.aspx

select count(*) from sys.dm_os_threads
select * from sys.dm_os_threads

-------------------------------------------------------------------------
Funções e exibições de gerenciamento dinâmico relacionadas ao sistema operacional do SQL Server (Transact-SQL)
http://technet.microsoft.com/pt-br/library/ms176083%28v=sql.105%29.aspx

-------------------------------------------------------------------------

*/

Select max_workers_count, * From sys.dm_os_sys_info

Select count(*) From sys.dm_os_threads --(857, 855, 856, 854, 865, 586, 644, 599, 569, 882)

--Select * From sys.dm_os_workers --(840, )
--Select * From sys.dm_os_schedulers
--Select * From sys.dm_os_nodes