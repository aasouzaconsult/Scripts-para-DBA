CREATE LOGIN NovoUsuario WITH PASSWORD = '<enterStrongPasswordHere>' MUST_CHANGE;
GO

sp_grantdbaccess 'NovoUsuario','Curso';
go

create user novouser for login NovoUsuario
go

Grant Select On Object::Curso.dbo.produtos To NovoUser

grant all privileges On produtos to junior

Execute As User='NovoUser'
Go
Select * from Produtos


