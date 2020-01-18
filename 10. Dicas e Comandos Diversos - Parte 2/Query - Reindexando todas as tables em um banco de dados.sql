--	Query - Reindexando todas as tables em um banco de dados
/*	Muitas vezes temos a necessidade de reorganizar todas as tables e seus índices existentes em um banco de dados 
específico, através desta dica fornecida pelo meu amigo MVP - Marcelo Colla, fica mais fácil realizar este procedimento.*/
 
Set NoCount On             
Declare @Tabelas Table (Idx Int Identity(1,1), TblName Varchar(100))             
Insert into @Tabelas (TblName)             
Select Table_Name From Information_Schema.Tables Where Table_Type = 'Base Table'              
             
Declare @Start Int             
Declare @End Int             
Declare @Command Varchar(1000)             
             
Select @Start = 1, @end = Max(Idx) From @Tabelas             
While @Start <= @End             
Begin             
  Select @Command = 'Dbcc DbReindex (' + TblName + ','''',90)' From @Tabelas Where Idx = @Start              
 
  Exec(@Command)             
 
  Set @Start = @Start + 1             
End