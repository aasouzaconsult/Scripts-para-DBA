Create Database DbAlex
On
Primary 
	(	Name = DbAlex_1
	,	FileName = 'D:\Banco\DbAlex_1.mdf'
	,	Size = 100MB
	,	MaxSize = Unlimited
	,	FileGrowth = 10%)
,	(	Name = DbAlex_2
	,	FileName = 'D:\Banco\DbAlex_2.ndf'
	,	Size = 100MB
	,	MaxSize = Unlimited
	,	FileGrowth = 10%)
Log on
	(	Name = DbAlex_Log
	,	FileName = 'D:\Banco\Log\DbAlex_Log.ldf'
	,	Size = 3MB
	,	MaxSize = Unlimited
	,	FileGrowth = 5MB )
Go

-- Adicionando um arquivo ao banco de dados
Alter Database DbAlex
Add File
	(	Name = DbAlex_3
	,	FileName = 'D:\Banco\DbAlex_3.ndf'
	,	Size = 100MB
	,	MaxSize = Unlimited
	,	FileGrowth = 10%)

-- Adicionando um grupo de arquivos (FileGroups)
Alter Database	DbAlex 
Add Filegroup	FG_Secundario

-- Adicionando arquivos e colocando-os em um grupo de arquivos
Alter Database DbAlex
Add File
	(	Name = DbAlex_4
	,	FileName = 'D:\Banco\DbAlex_4.ndf'
	,	Size = 10MB
	,	MaxSize = Unlimited
	,	FileGrowth = 5MB)
,	(	Name = DbAlex_5
	,	FileName = 'D:\Banco\DbAlex_5.ndf'
	,	Size = 10MB
	,	MaxSize = Unlimited
	,	FileGrowth = 5MB)
To FileGroup FG_Secundario

-- Configurando um FileGroup como Default
Alter Database DbAlex
Modify filegroup FG_Secundario Default

-- Modificando tamanho de um arquivo
Alter Database DbAlex
Modify File
	(	Name = DbAlex_5
	,	Size = 20MB)

-- Removendo um arquivo de uma Database
Use DbAlex
Dbcc shrinkfile (DbAlex_5, EMPTYFILE) /* Esvazia um arquivo movendo seus dados
para outros arquivos no mesmo grupo de arquivos (Filegroup)*/
Alter Database DbAlex
Remove File DbAlex_5 -- Aqui remove o arquivo

-- Configurando uma opção do Recovery Model
Alter Database DbAlex
Set recovery full
go

-- Configurando um usuário individual com reversão ou transações incompletas
--Alter Database DbAlex
--Set Single_User
--With Rollback immediate
--go