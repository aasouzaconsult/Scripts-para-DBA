/* Refazer a numeração seqüêncial de um campo do tipo inteiro, desta forma, respeitando uma ordem 
lógica de valores. */
 
CREATE TABLE #TEMP
( ITEM INT,
  NUMERO CHAR(6))

INSERT INTO #TEMP VALUES(1,'000008')
INSERT INTO #TEMP VALUES(2,'000008')
INSERT INTO #TEMP VALUES(3,'000008')
INSERT INTO #TEMP VALUES(4,'000008')
 
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

Select * from #Temp
 
delete from #Temp
Where item=3