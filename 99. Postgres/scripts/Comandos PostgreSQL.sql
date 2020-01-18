-- Versão
Select Version();

-- Encontrar e matar processo
select *, procpid from pg_stat_activity where datname = 'agromanager';
SELECT pg_terminate_backend(16193)

-- ou
SELECT 
    pg_terminate_backend(procpid) 
FROM 
    pg_stat_activity 
WHERE 
    -- don't kill my own connection!
    procpid <> pg_backend_pid()
    -- don't kill the connections to other databases
    AND datname = 'diego_agrom'
    ;

-- base
CREATE DATABASE agromanager
  WITH OWNER = agrom
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'pt_BR.UTF-8'
       LC_CTYPE = 'pt_BR.UTF-8'
       CONNECTION LIMIT = -1;

-- Reload
pg_ctl reload -D /var/lib/pgsql/9.1/data/


-- backup (homologação - diego_agrom) - pgadmin (windows)
 C:\Arquiv~1\PostgreSQL\9.1\bin\pg_dump.exe --host 10.251.0.100 --port 5432 --username postgres --format custom --blobs --verbose --file "C:\Backup_HOMOLO_SIGA_%date:~6,4%%date:~3,2%%date:~0,2%.backup" diego_agrom
