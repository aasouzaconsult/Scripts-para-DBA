-- Trabalhando com Aspas
Create Table TbTeste (
	CdTeste	int identity(1,1)
,	NmTeste	varchar(20));

Alter Table TbTeste
	Alter Column	NmTeste varchar(50);

Insert into TbTeste values ('Testando''''')

Update	TbTeste
Set		NmTeste = 'ISNULL(RCD.NRRCD, '''')'
Where   CdTeste = 1

Select * from TbTeste
Where	NmTeste like '%''%'