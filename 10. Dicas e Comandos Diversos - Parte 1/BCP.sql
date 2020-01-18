Declare @str varchar(255)
Declare @caminho varchar(255)
declare @err as varchar(255)
set @caminho = 'c:\temp'
set @str = 'bcp AdventureWorks.HumanResources.Employee out '+@Caminho+'\_'+datename(dw,getdate())+ '_'+ REPLACE(@@servername,'\','')
set @str = @str +'.sql -c -T -S'+@@servername+ ' -e'+@Caminho+'\Logins.err'
exec @err = master..xp_cmdshell @str, no_output