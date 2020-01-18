/*	Query - Refazendo a numeração em uma coluna
	Através desta dica, o leitor poderá refazer a numeração existente para um campo do tipo char, 
após ter excluído uma determinada quantidade de registros armazenados em uma table especificada, 
dentro de uma base de dados no SQL Server, sem ter a necessidade de apagar esta coluna.*/

CREATE TABLE #TEMP(
	ITEM INT
,	NUMERO CHAR(6))

INSERT INTO #TEMP VALUES(1,'000008')
INSERT INTO #TEMP VALUES(2,'000008')
INSERT INTO #TEMP VALUES(3,'000008')
INSERT INTO #TEMP VALUES(4,'000008')

Select * from #Temp

delete from #Temp Where item=3

Declare @Contador Int,
            @Linha Int

Set @Contador=(Select Max(Item) from #Temp)
Set @Linha=1

While @Linha < @Contador
  Begin
   If @Linha = (Select Item from #Temp Where Item = @Linha)
    Begin
     Update #Temp
     Set Item=@Linha 
     Where Item=@Linha
    End
   Else
    Begin
     Update #Temp
     Set Item=@Linha
     Where Item=@Linha+1
    End
   Set @Linha=@Linha+1
  End