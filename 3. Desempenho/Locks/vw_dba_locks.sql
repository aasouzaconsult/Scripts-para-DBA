USE [AnaliseInstancia]
GO

/****** Object:  View [dbo].[vw_dba_locks]    Script Date: 08/16/2013 15:48:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vw_dba_locks] AS

SELECT  er.wait_time                      AS WaitMSQty
      , er.session_id                     AS CallingSpId
      , LEFT(nt_user_name, 30)            AS CallingUserName
      , LEFT(ces.program_name, 40)        AS CallingProgramName
      , er.blocking_session_id            AS BlockingSpId
      , DB_NAME(er.database_id)           AS DbName
      , CAST(csql.text AS varchar(max))   AS CallingSQL
      , clck.CallingResourceId
      , clck.CallingResourceType
      , clck.CallingRequestMode
      , CAST(bsql.text AS varchar(max))   AS BlockingSQL
      , blck.BlockingResourceType
      , blck.BlockingRequestMode
FROM    master.sys.dm_exec_requests er WITH (NOLOCK)
        JOIN master.sys.dm_exec_sessions ces WITH (NOLOCK)
          ON er.session_id = ces.session_id
        CROSS APPLY fn_get_sql (er.sql_handle) csql
        JOIN (
-- Retrieve lock information for calling process, return only one record to 
-- report information at the session level
              SELECT  cl.request_session_id                 AS CallingSpId
                    , MIN(cl.resource_associated_entity_id) AS CallingResourceId
                    , MIN(LEFT(cl.resource_type, 30))       AS CallingResourceType
                    , MIN(LEFT(cl.request_mode, 30))        AS CallingRequestMode 
-- (i.e. schema, update, etc.)
              FROM    master.sys.dm_tran_locks cl WITH (nolock)
              WHERE   cl.request_status = 'WAIT' -- Status of the lock request = waiting
              GROUP BY cl.request_session_id
              ) AS clck
           ON er.session_id = clck.CallingSpid
         JOIN (
              -- Retrieve lock information for blocking process
              -- Only one record will be returned (one possibility, for instance, 
              -- is for multiple row locks to occur)
              SELECT  bl.request_session_id            AS BlockingSpId
                    , bl.resource_associated_entity_id AS BlockingResourceId
                    , MIN(LEFT(bl.resource_type, 30))  AS BlockingResourceType
                    , MIN(LEFT(bl.request_mode, 30))   AS BlockingRequestMode
              FROM    master.sys.dm_tran_locks bl WITH (nolock)
              GROUP BY bl.request_session_id
                    , bl.resource_associated_entity_id 
              ) AS blck
           ON er.blocking_session_id = blck.BlockingSpId
          AND clck.CallingResourceId = blck.BlockingResourceId
        JOIN master.sys.dm_exec_connections ber WITH (NOLOCK)
          ON er.blocking_session_id = ber.session_id
        CROSS APPLY fn_get_sql (ber.most_recent_sql_handle) bsql
WHERE   ces.is_user_process = 1
        AND er.wait_time > 0


GO


