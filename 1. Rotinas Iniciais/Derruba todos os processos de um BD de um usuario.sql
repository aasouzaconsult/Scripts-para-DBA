-- Derruba todos os processos de um BD de um determinado usuario

--Mata todos os processos do banco
USE master

-- Informe o nome do BD

Declare @BD varchar(max)
SET @BD = '' -- < Informe aqui o nome do BD

IF @BD = '' 
 BEGIN print ''
  RAISERROR ('Error: Informe o nome do banco de dados',
               16, -- Severity.
               1 -- State.
               );
 END

Declare @Id int 
Declare o_rs Cursor for 

Select spid 
From sysprocesses 
Where dbid = (Select dbid From sysdatabases Where name = @BD) 

Open o_rs 
Fetch next From o_rs Into @Id

While (@@Fetch_Status = 0) 
Begin 
	-- exec ('kill ' + @Id) 
	print ('kill ' + convert(varchar, @Id))
	Fetch next From o_rs Into @Id
End 

Close o_rs 
DealLocate o_rs