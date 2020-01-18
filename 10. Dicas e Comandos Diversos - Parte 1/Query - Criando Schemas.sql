/*	Coleção de Objetos dentro de um Database que permite agrupar objetos ao nível de
aplicações(Maior segurança).
	Pode atribuir usuarios a Schemas e etc. */

Use AdventureWorks
GO

Create Schema RH Authorization [dbo]

Create Table Funcionarios (
	Cod		int
,	Nome	varchar(50)
,	Descr	varchar(50))
GO