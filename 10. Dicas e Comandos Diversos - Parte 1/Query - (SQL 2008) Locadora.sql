USE master
go

-- Criando o Banco de Dados
IF DB_ID('DBLocadora') is not null
DROP DATABASE DBLocadora
go
CREATE DATABASE DBLocadora
go
USE DBLocadora
go

-- Criando as Tabelas
IF OBJECT_ID('TbPessoa') IS NOT NULL
	DROP table TbPessoa
GO
Create Table TbPessoa (
	CdPessoa	int identity(1,1) primary key
,	NmPessoa	varchar(300)
,	DtAnvPessoa	date -- Data Aniversário
,	RGPessoa	varchar(20)
,	CPFPessoa	varchar(14)
,	EndPessoa	varchar(500)
,	BaiPessoa	varchar(25)
,	CepPessoa	varchar(9)
,	CidPessoa	varchar(25)
,	CdEstado	int
,	CdPais		int
,	CdContato	int
,	foreign key (CdEstado)	references TbEstado (CdEstado)
,	foreign key	(CdPais)	references TbPais (CdPais)
,	foreign key (CdContato) references TbContato (CdContato)
)

IF OBJECT_ID('TbContato') IS NOT NULL
	DROP table TbContato
GO
Create table TbContato (
	CdContato int identity(1,1) primary key
,	Tel1Contato varchar(20)
,	Tel2Contato	varchar(20)
,	Tel3Contato varchar(20)
,	Cel1Contato varchar(20)
,	Cel2Contato varchar(20)
,	mailContato	varchar(150)
,	siteContato varchar(150)	
)

IF OBJECT_ID('TbEstado') IS NOT NULL
	DROP table TbEstado
GO
Create Table TbEstado (
	CdEstado	int identity (1,1) primary key
,	NmEstado	varchar(100)
,	SgEstado	varchar(2)
)

IF OBJECT_ID('TbPais') IS NOT NULL
	DROP table TbPais
GO
Create Table TbPais (
	CdPais		int identity (1,1) primary key
,	NmPais		varchar(150)
,	SgPais		varchar(3)	
)

IF OBJECT_ID ('TbCliente') IS NOT NULL
	DROP TABLE TbCliente
GO
Create Table TbCliente (
	CdCliente		int identity(1,1) primary key
,	NmCliente		varchar(300)
,	DtAtvCliente	date
,	DtDesCliente	date
,	CdPessoa		int
,	CdDependente	int
,	Foreign key (CdPessoa) references TbPessoa(CdPessoa)
,	Foreign key (CdDependente) references TbDependente(CdDependente)
)

IF OBJECT_ID('TbDependente') IS NOT NULL
	DROP TABLE TbDependente
GO
Create Table TbDependente (
	CdDependente	int identity(1,1) primary key
,	NmDependente	varchar(250)
,	ObsDependente	varchar(250)
,	CdPessoa		int
	Foreign key (CdPessoa) references TbPessoa (CdPessoa)
)

IF OBJECT_ID('TbFuncionario') IS NOT NULL
	DROP TABLE TbFuncionario
GO
Create table TbFuncionario (
	CdFuncionario	int identity(1,1) primary key
,	NmFuncionario	varchar(500)
,	StFuncionario	bit -- Status
,	TpFuncionario	varchar(200) -- Tipo
,	CdPessoa		int
	Foreign key (CdPessoa) references TbPessoa (CdPessoa)
)