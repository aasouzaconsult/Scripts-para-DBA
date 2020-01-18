/*If you need to get information out of your SQL server (2005 or 2008) quickly, execute the stored procedure and you will get a detailed report for the following areas

- Buffer statistics - Memory statistics - General statistics - Locks statistics/Totals for Locks statistics
- TempDB statistics - Totals of Database statistics - Plan Cache statistics - Transactions statistics
- SQL error statistics - SQL statistics (SQL compilations/recompilations) - Wait statistics - SQL Execution statistics

This script displays data from the dynamic management view called: 
sys.dm_os_performance_counters and presents it in a report. 
I recommend that you look closer to this view for all your statistical 
needs.

*/

 USE [master] -- Doesn't have to be in master database. 
--GO

--IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_dba_SQL_Server_Stats]') AND type in (N'P', N'PC'))
--DROP PROCEDURE [dbo].[usp_dba_SQL_Server_Stats]
--GO

/*SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_dba_SQL_Server_Stats]
AS*/

PRINT ' SQL 2005/2008 Server Statistics'
PRINT ' -------------------------------'
PRINT ''
PRINT ' Displaying statistics of SQL server '
PRINT ' '
PRINT '...Buffer Statistics'
PRINT ' '
SELECT
'Buffer Statistics' AS Counter_Object,
[counter_name] AS 'Description'
, [cntr_value] AS 'Current Value'
 from sys.dm_os_performance_counters 
WHERE 

   ([object_name] LIKE '%Buffer Manager%'and [counter_name] = 'Buffer cache hit ratio')
OR ([object_name] LIKE '%Buffer Manager%'and [counter_name] = 'Buffer cache hit ratio base')
OR ([object_name] LIKE '%Buffer Manager%'and [counter_name] = 'Page lookups/sec')
OR ([object_name] LIKE '%Buffer Manager%'and [counter_name] = 'Free pages')
OR ([object_name] LIKE '%Buffer Manager%'and [counter_name] = 'Total pages')
OR ([object_name] LIKE '%Buffer Manager%'and [counter_name] = 'Readahead pages/sec') 
OR ([object_name] LIKE '%Buffer Manager%'and [counter_name] = 'Page reads/sec')      
OR ([object_name] LIKE '%Buffer Manager%'and [counter_name] = 'Page writes/sec')     
OR ([object_name] LIKE '%Buffer Manager%'and [counter_name] = 'Page life expectancy')


PRINT '...Memory Statistics'
PRINT ' '
SELECT 
'Memory Statistics' AS Counter_Object,
[counter_name] AS 'Description'
, [cntr_value] AS 'Current Value'
 from sys.dm_os_performance_counters 
WHERE 
   ([object_name] LIKE '%memory manager%'and [counter_name] = 'Connection Memory (KB)')       
OR ([object_name] LIKE '%memory manager%'and [counter_name] = 'Granted Workspace Memory (KB)')
OR ([object_name] LIKE '%memory manager%'and [counter_name] = 'Lock Memory (KB)')             
OR ([object_name] LIKE '%memory manager%'and [counter_name] = 'Lock Blocks Allocated')        
OR ([object_name] LIKE '%memory manager%'and [counter_name] = 'Lock Owner Blocks Allocated')  
OR ([object_name] LIKE '%memory manager%'and [counter_name] = 'Lock Blocks')                  
OR ([object_name] LIKE '%memory manager%'and [counter_name] = 'Lock Owner Blocks')            
OR ([object_name] LIKE '%memory manager%'and [counter_name] = 'Maximum Workspace Memory (KB)')
OR ([object_name] LIKE '%memory manager%'and [counter_name] = 'Memory Grants Outstanding')    
OR ([object_name] LIKE '%memory manager%'and [counter_name] = 'Memory Grants Pending')        
OR ([object_name] LIKE '%memory manager%'and [counter_name] = 'Optimizer Memory (KB)')        
OR ([object_name] LIKE '%memory manager%'and [counter_name] = 'SQL Cache Memory (KB)')        
OR ([object_name] LIKE '%memory manager%'and [counter_name] = 'Target Server Memory (KB)')    
OR ([object_name] LIKE '%memory manager%'and [counter_name] = 'Total Server Memory (KB)')     


PRINT '...General Statistics'
PRINT ' '
SELECT 
'General Statistics' AS Counter_Object,
[counter_name] AS 'Description'
, [cntr_value] AS 'Current Value'
 from sys.dm_os_performance_counters 
WHERE
   ([object_name] LIKE '%General Statistics%'and [counter_name] = 'Active Temp Tables')                  	
OR ([object_name] LIKE '%General Statistics%'and [counter_name] = 'Temp Tables Creation Rate')
OR ([object_name] LIKE '%General Statistics%'and [counter_name] = 'Logins/sec')                          	
OR ([object_name] LIKE '%General Statistics%'and [counter_name] = 'Logouts/sec')                         	
OR ([object_name] LIKE '%General Statistics%'and [counter_name] = 'User Connections')                    	
OR ([object_name] LIKE '%General Statistics%'and [counter_name] = 'Logical Connections')                 	
OR ([object_name] LIKE '%General Statistics%'and [counter_name] = 'Transactions')                        	
OR ([object_name] LIKE '%General Statistics%'and [counter_name] = 'Mars Deadlocks')                      	
OR ([object_name] LIKE '%General Statistics%'and [counter_name] = 'HTTP Authenticated Requests')
OR ([object_name] LIKE '%General Statistics%'and [counter_name] = 'Processes blocked')                   	
OR ([object_name] LIKE '%General Statistics%'and [counter_name] = 'Temp Tables For Destruction')         	
OR ([object_name] LIKE '%General Statistics%'and [counter_name] = 'Event Notifications Delayed Drop')    	
OR ([object_name] LIKE '%General Statistics%'and [counter_name] = 'Trace Event Notification Queue')      	
OR ([object_name] LIKE '%General Statistics%'and [counter_name] = 'SQL Trace IO Provider Lock Waits')    	
			

PRINT '...Locks Statistics'
PRINT ' '
SELECT 
'Locks Statistics' AS Counter_Object,
[counter_name] AS 'Description'
, [cntr_value] AS 'Current Value'
 from sys.dm_os_performance_counters 
WHERE

   ([object_name] LIKE '%Locks%'and [counter_name] = 'Lock Timeouts/sec')
OR ([object_name] LIKE '%Locks%'and [counter_name] = 'Number of Deadlocks/sec')
OR ([object_name] LIKE '%Locks%'and [counter_name] = 'Lock Waits/sec')
OR ([object_name] LIKE '%Locks%'and [counter_name] = 'Lock Wait Time (ms)')
OR ([object_name] LIKE '%Locks%'and [counter_name] = 'Average Wait Time (ms)')
OR ([object_name] LIKE '%Locks%'and [counter_name] = 'Average Wait Time Base')
OR ([object_name] LIKE '%Locks%'and [counter_name] = 'Lock Timeouts (timeout > 0)/sec')

PRINT '...Total for Locks Statistics'
PRINT ' '
SELECT 
'Total for Locks Statistics' AS Counter_Object,
[counter_name] AS 'Description'
, [cntr_value] AS 'Current Value'
 from sys.dm_os_performance_counters 
WHERE

   ([object_name] LIKE '%Locks%'and [counter_name] = 'Lock Requests/sec' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Locks%'and [counter_name] = 'Lock Timeouts/sec' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Locks%'and [counter_name] = 'Number of Deadlocks/sec' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Locks%'and [counter_name] = 'Lock Waits/sec' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Locks%'and [counter_name] = 'Lock Wait Time (ms)' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Locks%'and [counter_name] = 'Average Wait Time (ms)' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Locks%'and [counter_name] = 'Average Wait Time Base' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Locks%'and [counter_name] = 'Lock Timeouts (timeout > 0)/sec' and [instance_name] ='_Total')
			

PRINT '...Temp DB Statistics'
PRINT ' '
SELECT 
'Temp DB Statistics' AS Counter_Object,
[counter_name] AS 'Description'
, [cntr_value] AS 'Current Value'
 from sys.dm_os_performance_counters 
WHERE

   ([object_name] LIKE '%Databases%'and [counter_name] = 'Data File(s) Size (KB)' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log File(s) Size (KB)' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log File(s) Used Size (KB)' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Percent Log Used' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Active Transactions' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Transactions/sec' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Repl. Pending Xacts' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Repl. Trans. Rate' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log Cache Reads/sec' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log Cache Hit Ratio' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log Cache Hit Ratio Base' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Bulk Copy Rows/sec' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Bulk Copy Throughput/sec' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Backup/Restore Throughput/sec' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'DBCC Logical Scan Bytes/sec' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Shrink Data Movement Bytes/sec' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log Flushes/sec' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log Bytes Flushed/sec' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log Flush Waits/sec' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log Flush Wait Time' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log Truncations' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log Growths' and [instance_name] ='tempdb')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log Shrinks' and [instance_name] ='tempdb')
																	


PRINT '...Totals of Database Statistics'
PRINT ' '
SELECT 
'Totals of Database Statistics' AS Counter_Object,
[counter_name] AS 'Description'
, [cntr_value] AS 'Current Value'
 from sys.dm_os_performance_counters 
WHERE

   ([object_name] LIKE '%Databases%'and [counter_name] = 'Data File(s) Size (KB)' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log File(s) Size (KB)' and [instance_name] ='_Total')          
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log File(s) Used Size (KB)' and [instance_name] ='_Total')     
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Percent Log Used' and [instance_name] ='_Total')               
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Active Transactions' and [instance_name] ='_Total')            
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Transactions/sec' and [instance_name] ='_Total')               
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Repl. Pending Xacts' and [instance_name] ='_Total')            
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Repl. Trans. Rate' and [instance_name] ='_Total')              
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log Cache Reads/sec' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log Cache Hit Ratio' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log Cache Hit Ratio Base' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Bulk Copy Rows/sec' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Bulk Copy Throughput/sec' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Backup/Restore Throughput/sec' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'DBCC Logical Scan Bytes/sec' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Shrink Data Movement Bytes/sec' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log Flushes/sec' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log Bytes Flushed/sec' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log Flush Waits/sec' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log Flush Wait Time' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log Truncations' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log Growths' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Databases%'and [counter_name] = 'Log Shrinks' and [instance_name] ='_Total')



PRINT '...SQL Error Statistics'
PRINT ' '
SELECT 
'SQL Error Statistics' AS Counter_Object,
  [instance_name] AS 'Description'
, [cntr_value] AS 'Current Value'
 from sys.dm_os_performance_counters 
WHERE

   ([object_name] LIKE '%SQL Errors%'and [counter_name] = 'Errors/sec')
OR ([object_name] LIKE '%SQL Errors%'and [counter_name] = 'Errors/sec')
OR ([object_name] LIKE '%SQL Errors%'and [counter_name] = 'Errors/sec')
OR ([object_name] LIKE '%SQL Errors%'and [counter_name] = 'Errors/sec')
OR ([object_name] LIKE '%SQL Errors%'and [counter_name] = 'Errors/sec')



PRINT '...SQL Statistics'
PRINT ' '
SELECT 
'SQL Statistics' AS Counter_Object,
[counter_name] AS 'Description'
, [cntr_value] AS 'Current Value'
 from sys.dm_os_performance_counters 
WHERE
   ([object_name] LIKE '%SQL Statistics%'and [counter_name] = 'SQL Compilations/sec')
OR ([object_name] LIKE '%SQL Statistics%'and [counter_name] = 'SQL Re-Compilations/sec')



PRINT '...Plan Cache Statistics'
PRINT ' '
SELECT 
'Plan Cache Statistics' AS Counter_Object,
[counter_name] AS 'Description'
, [cntr_value] AS 'Current Value'
 from sys.dm_os_performance_counters 
WHERE
   ([object_name] LIKE '%Plan Cache%'and [counter_name] = 'Cache Hit Ratio' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Plan Cache%'and [counter_name] = 'Cache Hit Ratio Base' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Plan Cache%'and [counter_name] = 'Cache Pages' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Plan Cache%'and [counter_name] = 'Cache Object Counts' and [instance_name] ='_Total')
OR ([object_name] LIKE '%Plan Cache%'and [counter_name] = 'Cache Objects in use' and [instance_name] ='_Total')


PRINT '...Transactions Statistics'
PRINT ' '
SELECT 
'Transactions Statistics' AS Counter_Object,
[counter_name] AS 'Description'
, [cntr_value] AS 'Current Value'
 from sys.dm_os_performance_counters 
WHERE ([object_name] LIKE '%Transactions%')


PRINT '...Wait Statistics. Average execution time (ms)'
PRINT ' '
SELECT 
'Wait Statistics. Average execution time (ms)' AS Counter_Object,
[counter_name] AS 'Description'
, [cntr_value] AS 'Current Value'
 from sys.dm_os_performance_counters 
WHERE ([object_name] LIKE '%Wait Statistics%'and [instance_name] = 'Average execution time (ms)')                          

--
PRINT '...Wait Statistics. Waits in progress'
PRINT ' '
SELECT
'Wait Statistics. Waits in progress' AS Counter_Object,
[counter_name] AS 'Description'
, [cntr_value] AS 'Current Value'
 from sys.dm_os_performance_counters 
WHERE ([object_name] LIKE '%Wait Statistics%'and [instance_name] = 'Waits in progress')    

--
PRINT '...SQL Execution Statistics. Average execution time (ms)'
PRINT ' '
SELECT 
'SQL Execution Statistics. Average execution time (ms)' AS Counter_Object,
[counter_name] AS 'Description'
, [cntr_value] AS 'Current Value'
 from sys.dm_os_performance_counters 
WHERE
   ([object_name] LIKE '%Exec Statistics%'and [counter_name] = 'Extended Procedures')  
OR ([object_name] LIKE '%Exec Statistics%'and [counter_name] = 'DTC calls')            
OR ([object_name] LIKE '%Exec Statistics%'and [counter_name] = 'OLEDB calls')          
OR ([object_name] LIKE '%Exec Statistics%'and [counter_name] = 'Distributed Query')    
																				
--
PRINT '...SQL Execution Statistics. Execution in progress'
PRINT ' '
SELECT
'SQL Execution Statistics. Execution in progress' AS Counter_Object,
[counter_name] AS 'Description'
, [cntr_value] AS 'Current Value'
 from sys.dm_os_performance_counters 
WHERE ([object_name] LIKE '%Exec Statistics' and [instance_name] ='Execs in progress')
GO
