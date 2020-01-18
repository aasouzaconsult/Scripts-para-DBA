Use DBTeste
/*************************************************
 * Usando Date, Time, DateTimeOffSet e DateTime2 *
 *************************************************/
IF OBJECT_ID ('TbNovosTipos') IS NOT NULL
	DROP TABLE TbNovosTipos
GO
Create Table TbNovosTipos(
	campoDate Date
,	campoTime Time(5) -- Precisão de 7 casas
/*  O tipo de dados datetimeoffset proporciona reconhecimento do fuso horário */
,	campoOffSet Datetimeoffset
/*  O tipo de dados datetime2 é uma extensão do tipo datetime original. Ele dá 
suporte a um intervalo de datas maior e a mais precisão fracionária em segundos, 
além de lhe permitir especificar essa precisão*/
,	campoDatetime2 Datetime2) 

Insert into TbNovosTipos values (getDate(),getDate(),getDate(),getDate())
Select * From tbNovosTipos

/**********************************************
 * Detalhando o DateTimeOffSet (Fuso Horário) *
 **********************************************/
DECLARE @DtBrasilia DATETIMEOFFSET(0)
SET @DtBrasilia = '20080415 22:00:00 -3:00' -- Brasilia

DECLARE @DtTokio DATETIMEOFFSET(0)
SET @DtTokio = '20080415 22:00:00 +9:00' -- Tokio

SELECT DATEDIFF(hh,@DtBrasilia,@DtTokio) 'Diferença Fuso Brasilia e Tokio'

dbcc showcontig

/*****************************
 * Tipo de Dado: Hierarchyid *
 *****************************/
USE MASTER
GO

CREATE DATABASE MinhaEmpresa
GO
USE MinhaEmpresa
GO

-- Criando a tabela    
CREATE TABLE TbEmpregados (
    CdEmp	int NOT NULL
,	NmEmp	varchar(50) NOT NULL
,	CgEmp	varchar(50) NULL -- Cargo
,	SalEmp	decimal(18, 2) NOT NULL
,	HieEmp	datetimeoffset(0) NOT NULL
,	Hierarquia	hierarchyid NOT NULL)
GO
delete TbEmpregados

DECLARE 
	@Empregado	hierarchyid
,	@Gerente	hierarchyid = hierarchyid::GetRoot()

-- Topo da arvore
INSERT INTO TbEmpregados VALUES (6, 'Antonio Alex', 'CEO', 35900.00, '2000-05-23T08:30:00-08:00', @Gerente)

-- Inserir os Empregados do Antonio Alex (2 Nivel)
SELECT @Empregado = @Gerente.GetDescendant(NULL, NULL)
INSERT INTO TbEmpregados VALUES(46, 'Tiririca', 'Especialista SQL Server', 14000.00, '2002-05-23T09:00:00-08:00', @Empregado)

SELECT @Empregado = @Gerente.GetDescendant(@Empregado, NULL)
INSERT INTO TbEmpregados VALUES(271, 'Falcao', 'Especialista Oracle', 14000.00,'2002-05-23T09:00:00-08:00', @Empregado)

SELECT @Empregado = @Gerente.GetDescendant(@Empregado, NULL) 
INSERT INTO TbEmpregados VALUES(119, 'Adamastor P.', 'Especialista MySQL', 14000.00, '2007-05-23T09:00:00-08:00', @Empregado)

-- (3 Nível)
-- Insira os funcionario do Empregado 46 (Tiririca)
SELECT @Gerente = Hierarquia.GetDescendant(NULL, NULL) FROM TbEmpregados WHERE CdEmp = 46
INSERT INTO TbEmpregados VALUES(269, 'Rosiclea', 'Assistente DB', 8000.00, '2003-05-23T09:00:00-08:00', @Gerente)

-- Insira os funcionario do Empregado 271 (Falcao)
SELECT @Gerente = Hierarquia.GetDescendant(NULL, NULL) FROM TbEmpregados WHERE CdEmp = 271
INSERT INTO TbEmpregados VALUES(272, 'Babau do Pandeiro', 'Assistente DB', 8000.00, '2004-05-23T09:00:00-08:00', @Gerente)

SELECT @Gerente = Hierarquia.GetDescendant(@Gerente, NULL) FROM TbEmpregados WHERE CdEmp = 271
INSERT INTO TbEmpregados VALUES(273, 'Alysson S.', 'Assistente DB', 8000.00, '2004-05-23T09:00:00-08:00', @Gerente)

-- (4 Nível)
-- Insira os funcionario do Empregado 272 (Babau do Pandeiro)
SELECT @Gerente = Hierarquia.GetDescendant(NULL, NULL) FROM TbEmpregados WHERE CdEmp = 272
INSERT INTO TbEmpregados VALUES(300, 'Babau do Pandeiro Jr.', 'Estagiario DB', 4000.00, '2004-05-23T09:00:00-08:00', @Gerente)
GO

SELECT 
		NmEmp
,		CgEmp
,		SalEmp
,		Hierarquia.ToString() AS Hierarquia
FROM	TbEmpregados 
ORDER BY 
		Hierarquia
GO