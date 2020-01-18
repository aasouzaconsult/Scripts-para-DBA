-- SQL and OS Version information for current instance  (Query 1)
SELECT @@SERVERNAME AS [Server Name], @@VERSION AS [SQL Server and OS Version Info];

-- SQL Server 2008 RTM is considered an "unsupported service pack" as of April 13, 2010
-- SQL Server 2008 SP1 is considered an "unsupported service pack" as of September 19, 2011

-- SQL Server 2008 RTM Builds   SQL Server 2008 SP1 Builds     SQL Server 2008 SP2 Builds		SQL Server 2008 SP3 Builds
-- Build       Description      Build       Description		   Build     Description			Build		Description
-- 1600        Gold RTM
-- 1763        RTM CU1
-- 1779        RTM CU2
-- 1787        RTM CU3    -->	2531		SP1 RTM
-- 1798        RTM CU4    -->	2710        SP1 CU1
-- 1806        RTM CU5    -->	2714        SP1 CU2 
-- 1812		   RTM CU6    -->	2723        SP1 CU3
-- 1818        RTM CU7    -->	2734        SP1 CU4
-- 1823        RTM CU8    -->	2746		SP1 CU5
-- 1828		   RTM CU9    -->	2757		SP1 CU6
-- 1835		   RTM CU10   -->	2766		SP1 CU7
-- RTM Branch Retired     -->	2775		SP1 CU8		-->  4000	   SP2 RTM
--								2789		SP1 CU9
--								2799		SP1 CU10	
--								2804		SP1 CU11	-->  4266      SP2 CU1		
--								2808		SP1 CU12	-->  4272	   SP2 CU2	
--								2816	    SP1 CU13    -->  4279      SP2 CU3	
--								2821		SP1 CU14	-->  4285	   SP2 CU4	-->				5500		SP3 RTM
--								2847		SP1 CU15	-->  4316	   SP2 CU5  
--								2850		SP1 CU16	-->  4321	   SP2 CU6	-->				5766		SP3 CU1	
--                              SP1 Branch Retired      -->  4323      SP2 CU7  -->             5768        SP3 CU2
--                                                           4326	   SP2 CU8  -->             5770		SP3 CU3
--														     4330	   SP2 CU9  -->				5775		SP3 CU4
--															 4332	   SP2 CU10 -->             5785        SP3 CU5
--															 4333      SP2 CU11 -->			    5788        SP3 CU6

-- The SQL Server 2008 builds that were released after SQL Server 2008 was released
-- http://support.microsoft.com/kb/956909

-- The SQL Server 2008 builds that were released after SQL Server 2008 Service Pack 1 was released
-- http://support.microsoft.com/kb/970365
--
-- The SQL Server 2008 builds that were released after SQL Server 2008 Service Pack 2 was released 
-- http://support.microsoft.com/kb/2402659	
--
-- The SQL Server 2008 builds that were released after SQL Server 2008 Service Pack 3 was released
-- http://support.microsoft.com/kb/2629969					   


-- SQL Server 2008 R2 RTM was considered an "unsupported service pack" as of July 12, 2012

-- SQL Server 2008 R2 Builds				SQL Server 2008 R2 SP1 Builds			SQL Server 2008 R2 SP2 Builds
-- Build			Description				Build		Description					Build		Description
-- 10.50.1092		August 2009 CTP2		
-- 10.50.1352		November 2009 CTP3
-- 10.50.1450		Release Candidate
-- 10.50.1600		RTM
-- 10.50.1702		RTM CU1
-- 10.50.1720		RTM CU2
-- 10.50.1734		RTM CU3
-- 10.50.1746		RTM CU4
-- 10.50.1753		RTM CU5
-- 10.50.1765		RTM CU6	 --->			10.50.2500	SP1 RTM
-- 10.50.1777		RTM CU7
-- 10.50.1797		RTM CU8	 --->			10.50.2769  SP1 CU1
-- 10.50.1804       RTM CU9  --->			10.50.2772  SP1 CU2
-- 10.50.1807		RTM CU10 --->           10.50.2789  SP1 CU3
-- 10.50.1809       RTM CU11 --->			10.50.2796  SP1 CU4 
-- 10.50.1810		RTM CU12 --->			10.50.2806	SP1 CU5		--->			10.50.4000	SP2 RTM
-- 10.50.1815		RTM CU13 --->           10.50.2811  SP1 CU6
-- 10.50.1817		RTM CU14 --->			10.50.2817  SP1 CU7		--->			10.50.4260	SP1 CU1   
-- RTM Branch Retired        --->   

-- The SQL Server 2008 R2 builds that were released after SQL Server 2008 R2 was released
-- http://support.microsoft.com/kb/981356

-- The SQL Server 2008 R2 builds that were released after SQL Server 2008 R2 Service Pack 1 was released 
-- http://support.microsoft.com/kb/2567616

-- The SQL Server 2008 R2 builds that were released after SQL Server 2008 R2 Service Pack 2 was released
-- http://support.microsoft.com/kb/2730301 


-- When was SQL Server installed  (Query 2)   
SELECT @@SERVERNAME AS [Server Name], createdate AS [SQL Server Install Date] 
FROM sys.syslogins 
WHERE [sid] = 0x010100000000000512000000;

-- Tells you the date and time that SQL Server was installed
-- It is a good idea to know how old your instance is


-- Get selected server properties (SQL Server 2008)  (Query 3)
SELECT SERVERPROPERTY('MachineName') AS [MachineName], SERVERPROPERTY('ServerName') AS [ServerName],  
SERVERPROPERTY('InstanceName') AS [Instance], SERVERPROPERTY('IsClustered') AS [IsClustered], 
SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS [ComputerNamePhysicalNetBIOS], 
SERVERPROPERTY('Edition') AS [Edition], SERVERPROPERTY('ProductLevel') AS [ProductLevel], 
SERVERPROPERTY('ProductVersion') AS [ProductVersion], SERVERPROPERTY('ProcessID') AS [ProcessID],
SERVERPROPERTY('Collation') AS [Collation], SERVERPROPERTY('IsFullTextInstalled') AS [IsFullTextInstalled], 
SERVERPROPERTY('IsIntegratedSecurityOnly') AS [IsIntegratedSecurityOnly];

-- This gives you a lot of useful information about your instance of SQL Server


-- Windows information (SQL Server 2008 R2 SP1 or greater)  (Query 4)
SELECT windows_release, windows_service_pack_level, 
       windows_sku, os_language_version
FROM sys.dm_os_windows_info WITH (NOLOCK) OPTION (RECOMPILE);

-- Gives you major OS version, Service Pack, Edition, and language info for the operating system


-- SQL Server Services information (SQL Server 2008 R2 SP1 or greater)  (Query 5)
SELECT servicename, startup_type_desc, status_desc, 
last_startup_time, service_account, is_clustered, cluster_nodename
FROM sys.dm_server_services WITH (NOLOCK) OPTION (RECOMPILE);

-- Tells you the account being used for the SQL Server Service and the SQL Agent Service
-- Shows when they were last started, and their current status
-- Shows whether you are running on a failover cluster



-- SQL Server NUMA Node information  (Query 6)
SELECT node_id, node_state_desc, memory_node_id, online_scheduler_count, 
       active_worker_count, avg_load_balance 
FROM sys.dm_os_nodes WITH (NOLOCK) 
WHERE node_state_desc <> N'ONLINE DAC' OPTION (RECOMPILE);

-- Gives you some useful information about the composition 
-- and relative load on your NUMA nodes




-- Hardware information from SQL Server 2008 and 2008 R2  (Query 7)
-- (Cannot distinguish between HT and multi-core)
SELECT cpu_count AS [Logical CPU Count], hyperthread_ratio AS [Hyperthread Ratio],
cpu_count/hyperthread_ratio AS [Physical CPU Count], 
physical_memory_in_bytes/1048576 AS [Physical Memory (MB)], 
sqlserver_start_time --, affinity_type_desc -- (affinity_type_desc is only in 2008 R2)
FROM sys.dm_os_sys_info WITH (NOLOCK) OPTION (RECOMPILE);

-- Gives you some good basic hardware information about your database server


-- Get System Manufacturer and model number from  (Query 8) 
-- SQL Server Error log. This query might take a few seconds 
-- if you have not recycled your error log recently
EXEC xp_readerrorlog 0,1,"Manufacturer"; 

-- This can help you determine the capabilities
-- and capacities of your database server


-- Get processor description from Windows Registry  (Query 9)
EXEC xp_instance_regread 
'HKEY_LOCAL_MACHINE', 'HARDWARE\DESCRIPTION\System\CentralProcessor\0',
'ProcessorNameString';

-- Gives you the model number and rated clock speed of your processor(s)
-- Your processors may be running at less that the rated clock speed due
-- to the Windows Power Plan or hardware power management


-- Get the current node name from your cluster nodes  (Query 10)
-- (if your database server is in a cluster)
SELECT NodeName
FROM sys.dm_os_cluster_nodes WITH (NOLOCK) OPTION (RECOMPILE);

-- Knowing which node owns the cluster resources is critical
-- Especially when you are installing Windows or SQL Server updates
-- You will see no results if your instance is not clustered


-- Get configuration values for instance  (Query 11)
SELECT name, value, value_in_use, [description] 
FROM sys.configurations WITH (NOLOCK)
ORDER BY name OPTION (RECOMPILE);

-- Focus on
-- backup compression default
-- clr enabled (only enable if it is needed)
-- lightweight pooling (should be zero)
-- max degree of parallelism (depends on your workload)
-- max server memory (MB) (set to an appropriate value)
-- optimize for ad hoc workloads (should be 1)
-- priority boost (should be zero)


-- SQL Server Registry information (SQL Server 2008 R2 SP1 or greater)  (Query 12)
SELECT registry_key, value_name, value_data
FROM sys.dm_server_registry WITH (NOLOCK) OPTION (RECOMPILE);

-- This lets you safely read some SQL Server related 
-- information from the Windows Registry


-- Get information on location, time and size of any memory dumps from SQL Server (SQL Server 2008 R2 SP1 or greater)  (Query 13)
SELECT [filename], creation_time, size_in_bytes
FROM sys.dm_server_memory_dumps WITH (NOLOCK) OPTION (RECOMPILE);

-- This will not return any rows if you have 
-- not had any memory dumps (which is a good thing)


-- File Names and Paths for TempDB and all user databases in instance  (Query 14) 
SELECT DB_NAME([database_id])AS [Database Name], 
       [file_id], name, physical_name, type_desc, state_desc, 
       CONVERT( bigint, size/128.0) AS [Total Size in MB]
FROM sys.master_files WITH (NOLOCK)
WHERE [database_id] > 4 
AND [database_id] <> 32767
OR [database_id] = 2
ORDER BY DB_NAME([database_id]) OPTION (RECOMPILE);

-- Things to look at:
-- Are data files and log files on different drives?
-- Is everything on the C: drive?
-- Is TempDB on dedicated drives?
-- Is there only one TempDB data file?
-- Are all of the TempDB data files the same size?
-- Are there multiple data files for user databases?


-- Volume info for all databases on the current instance (SQL Server 2008 R2 SP1 or greater)  (Query 15)
SELECT DB_NAME(f.database_id) AS [DatabaseName], f.file_id, 
vs.volume_mount_point, vs.total_bytes, vs.available_bytes, 
CAST(CAST(vs.available_bytes AS FLOAT)/ CAST(vs.total_bytes AS FLOAT) AS DECIMAL(18,3)) * 100 AS [Space Free %]
FROM sys.master_files AS f WITH (NOLOCK)
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs
ORDER BY f.database_id OPTION (RECOMPILE);

--Shows you the free space on the LUNs where you have database data or log files


-- Recovery model, log reuse wait description, log file size, log usage size  (Query 16) 
-- and compatibility level for all databases on instance
SELECT db.[name] AS [Database Name]
     , db.recovery_model_desc AS [Recovery Model]
     , db.log_reuse_wait_desc AS [Log Reuse Wait Description]
     , ls.cntr_value AS [Log Size (KB)], lu.cntr_value AS [Log Used (KB)]
     , CAST(CAST(lu.cntr_value AS FLOAT) / CAST(ls.cntr_value AS FLOAT)AS DECIMAL(18,2)) * 100 AS [Log Used %]
     , collation_name
     , db.[compatibility_level] AS [DB Compatibility Level], 
db.page_verify_option_desc AS [Page Verify Option], db.is_auto_create_stats_on, db.is_auto_update_stats_on,
db.is_auto_update_stats_async_on, db.is_parameterization_forced, 
db.snapshot_isolation_state_desc, db.is_read_committed_snapshot_on,
db.is_auto_close_on, db.is_auto_shrink_on
FROM sys.databases AS db WITH (NOLOCK)
INNER JOIN sys.dm_os_performance_counters AS lu WITH (NOLOCK)
ON db.name = lu.instance_name
INNER JOIN sys.dm_os_performance_counters AS ls WITH (NOLOCK) 
ON db.name = ls.instance_name
WHERE lu.counter_name LIKE N'Log File(s) Used Size (KB)%' 
AND ls.counter_name LIKE N'Log File(s) Size (KB)%'
AND ls.cntr_value > 0 OPTION (RECOMPILE);