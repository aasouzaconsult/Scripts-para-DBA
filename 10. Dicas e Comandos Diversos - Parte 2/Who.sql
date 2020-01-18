--Quais os usuiários estão a mais tempo conectados com o estado 
--de SUSPENDED ou RUNNING
SELECT 
    t1.session_id,
    CONVERT(varchar(10), t1.status) AS status,
    CONVERT(varchar(15), t1.command) AS command,
    CONVERT(varchar(10), t2.state) AS worker_state,
    w_suspended = 
      CASE t2.wait_started_ms_ticks
        WHEN 0 THEN 0
        ELSE 
          t3.ms_ticks - t2.wait_started_ms_ticks
      END,
    w_runnable = 
      CASE t2.wait_resumed_ms_ticks
        WHEN 0 THEN 0
        ELSE 
          t3.ms_ticks - t2.wait_resumed_ms_ticks
      END
FROM 
	sys.dm_exec_requests AS t1
INNER JOIN 
	sys.dm_os_workers AS t2
ON 
	t2.task_address = t1.task_address
CROSS JOIN 
	sys.dm_os_sys_info AS t3
WHERE 
	t1.scheduler_id IS NOT NULL
ORDER BY 
	t1.session_id DESC;
GO

sp_who2 active
go


--sp_who active
