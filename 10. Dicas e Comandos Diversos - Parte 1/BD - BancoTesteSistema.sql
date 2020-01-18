CREATE DATABASE BancoTesteSistema
USE BancoTesteSistema 

-- Criação de Tabelas
CREATE TABLE TbEndereco ( --drop table TbEndereco
	CdEndereco		INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	TipoEndereço	VARCHAR(10),	
	DescEndereco	VARCHAR(60),
	NumEndereco		VARCHAR(10),
	ComplEndereco	VARCHAR(50),
	BairroEndereco  VARCHAR(25),
	CidadeEndereco	VARCHAR(25),
	EstadoEndereco  VARCHAR(25),
	RegiaoEndereco	VARCHAR(25),
    PaisEndereco	VARCHAR(25)
)

CREATE TABLE TbPessoa (  --drop table TbPessoa
	CdPessoa	INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	TipoPessoa	CHAR,
	RgPessoa VARCHAR(15),
	CpfPessoa VARCHAR(11),
	NmPessoa	VARCHAR(50),
	CdEndPessoa INT,
	CepPessoa	VARCHAR(10),
	TelPessoa	VARCHAR(10),
	EMailPessoa VARCHAR(50),
	DtCadPessoa DATETIME,
    FOREIGN KEY (CdEndPessoa) REFERENCES TbEndereco(CdEndereco)	
)

CREATE TABLE TbFornecedor ( --drop table TbFornecedor
	CdFornecedor		INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	NmFantFornecedor	VARCHAR(50),
	CdPesFornecedor		INT,
	CdObjFornecedor		INT,
	FOREIGN KEY (CdPesFornecedor) REFERENCES TbPessoa (CdPessoa)
)

CREATE TABLE TbObjeto ( --drop table TbObjeto
	CdObjeto			INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	NmObjeto			VARCHAR(50),
	UnidadeObjeto		VARCHAR(40),
	PesoObjeto			FLOAT,
	EstMinimoObjeto		FLOAT,
	LoteMinimoObjeto	FLOAT,
	QtdObjeto			FLOAT,
	CdFornObjeto		INT,
	FOREIGN KEY (CdFornObjeto) REFERENCES TbFornecedor(CdFornecedor)
)

CREATE TABLE TbPedidoCompra (  --drop table TbPedidoCompra
	CdPedCompra INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	DtPedCompra DATETIME,
	CdObjPedCompra INT,
	ComplPedCompra VARCHAR(25),
	CdFornPedCompra INT,
	QtdPedCompra FLOAT,
	ValorPedCompra FLOAT,
	ValorTotPedCompra FLOAT,
	PagamentoPedCompra VARCHAR(15),
	FOREIGN KEY (CdObjPedCompra) REFERENCES TbObjeto(CdObjeto),
	FOREIGN KEY (CdFornPedCompra) REFERENCES TbFornecedor(CdFornecedor)
)

-- Views
--Create View VwPessoaCidade as 
Alter View VwPessoaCidade as
select
		Nome = Pes.NmPessoa
,		Cidade = Ende.CidadeEndereco
,		Regiao = Ende.RegiaoEndereco
,		Pais = Ende.PaisEndereco
From	TbPessoa Pes
Join	TbEndereco Ende on Ende.CdEndereco = Pes.CdEndPessoa

-- Inserindo Dados em tabelas
insert into TbEndereco values ('Rua', 'D', '621', 'Loteamento Planalto Sul', 'Passaré', 'Fortaleza', 'Ceará', 'Nordeste', 'Brasil')
insert into TbEndereco values ('Rua', 'E', '500', 'Loteamento Planalto Sul', 'Passaré', 'Fortaleza', 'Ceará', 'Nordeste', 'Brasil')
insert into TbEndereco values ('Avenida', 'Ede', '1500', ' ', 'Vila Ede', 'São Paulo', 'São Paulo', 'Sudeste', 'Brasil')

insert into TbPessoa values ('M','1234567', '29393405890', 'Antonio Alex', 1, '60994-300', '3222-3222', 'alex@sql.com.br', '20050101')
insert into TbPessoa values ('M','3456789', '12345678902', 'Alysson Silva', 2, '60334-900', '3235-3222', 'alysson@exodus.com.br', '20050101')
insert into TbPessoa values ('F','2345678', '12345678903', 'Jose Antonio', 3, '60224-200', '3235-3222', 'marialucia@mercadinhosrpassare.com.br', '20060531')

-- Comandos auxiliares diversos
--update	TbPessoa
set		DtCadPessoa = '20060531'
where	CdPessoa = 1

--alter table TbPessoa add CpfPessoa VARCHAR(11)
--alter table TbPessoa drop column CgfRgPessoa

-- Select's
select * from TbEndereco
select * from TbPessoa
select * from TbFornecedor
select * from TbObjeto
select * from TbPedidoCompra
select * from VwPessoaCidade -- View

select
		Pes.NmPessoa
,		Pes.CpfPessoa
,		Ende.TipoEndereço
,		Ende.DescEndereco
,		Ende.BairroEndereco
,		Ende.CidadeEndereco
,		Pes.EmailPessoa
,		CpfValido = dbo.Fun_ValidarCPF(Pes.CpfPessoa) --Validando CPF
From	TbPessoa Pes 
Join	TbEndereco Ende on Pes.CdEndPessoa = Ende.CdEndereco