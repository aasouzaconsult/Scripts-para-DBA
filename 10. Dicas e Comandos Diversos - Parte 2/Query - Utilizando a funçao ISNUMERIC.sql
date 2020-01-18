/*Como utilizar a função IsNumeric para realizar uma verificação tendo como base um registro com 
valores numéricos e retornar caso exista um caracter neste registro a parte caracter.*/

--Exemplo 1
Declare @Texto Varchar(20)
Set @Texto='1000G00'

If IsNumeric(SubString(@Texto,5,1))=0
	Print SubString(@Texto,5,1)+'Não é numérico'

--Exemplo 2
Declare @String varchar(1000)
Set @string = '1000G00'

Declare @Start int
Declare @End int

Select @Start = 1, @end = len(@String)
	While @start <= @end
		Begin
			If Isnumeric(substring(@String,@Start,1))=0
				Print substring(@String,@Start,1) + ' nao e numerico '
				 Set @Start = @Start + 1
		End