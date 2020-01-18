grant select on object:: teste.dbo.teste to uservp
grant select on object:: teste.dbo.teste to useradhoc
grant select on object:: teste.dbo.teste to userMarketing

grant insert on object:: teste.dbo.teste to uservp
grant insert on object:: teste.dbo.teste to useradhoc
grant insert on object:: teste.dbo.teste to userMarketing
go


Execute As Login ='UserVP'
SELECT [Codigo]
      ,[Descricao]
  FROM [TESTE].[dbo].[Teste]
GO


Execute As Login ='UserAdHoc'
SELECT [Codigo]
      ,[Descricao]
  FROM [TESTE].[dbo].[Teste]
GO


Execute As Login ='UserAdHoc'
go
  
Declare @Contador Int

Set @contador=1

While @Contador <=100000000
 Begin
  
  Select * from Teste
  
  Set @Contador=@Contador+1
 End
 
Execute As Login ='UserVP'
go
Insert Into teste default values
Go 100000   
Go 

Execute As Login ='UserMarketing'
go
Insert Into teste default values
Go 100000
Go


Execute As Login ='UserAdHoc'
go
Insert Into teste default values
Go 100000
Go