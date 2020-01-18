-- O script abaixo apresenta o "database recovery model " do banco de dados desejado:
 
create table #temp
 (
name varchar(20), 
db_size nvarchar(50), 
owner varchar(50), 
dbid smallint, 
created datetime, 
status varchar(8000), 
compatability_level smallint
)
insert into #temp exec sp_helpdb

select name,replace(replace(substring(status, patindex 
       ('%recovery=%',status)+9, 11), ', Ver',''),'FULLsi','FULL') as recovery_model
from #temp

drop table #temp
