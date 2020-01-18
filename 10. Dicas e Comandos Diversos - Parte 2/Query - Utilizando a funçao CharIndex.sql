Create Table #ExemploCharIndex (
	CampoTexto VarChar(100))

--drop table #ExemploCharIndex

Insert Into #ExemploCharIndex Values('Com Espaço')
Insert Into #ExemploCharIndex Values('Sem_Espaço')
Insert Into #ExemploCharIndex Values('Testando1')
Insert Into #ExemploCharIndex Values('Testando 2 e 3')
Insert Into #ExemploCharIndex Values('Teste(),TESTE__)(')
Insert Into #ExemploCharIndex Values('Teste(),TESTE__)( ')

Select 
	CampoTexto
,	[Tem Espaço ?] = Case 
						When CharIndex(' ', CampoTexto, 1) = 0 Then 'Não Tem' Else 'Tem'
					 End
From #ExemploCharIndex