-- Query - Simulando um Deadlock

-- Criando o Banco de Dados para Simulação
CREATE DATABASE DBDeadLock

-- Utilizar o BD
USE DBDeadLock


-- Criando as tabelas...
CREATE TABLE TbDeadCliente (
	CdDeadCliente	int	identity(1,1) primary key
,	NmCliente		varchar(200)
,	EndCliente		varchar(200))

CREATE TABLE TbDeadPedido (
	CdDeadPedido		int	identity(1,1) primary key
,	NmClientePedido		varchar(200)		
,	EndClientePedido	varchar(200))

--drop table TbDeadCliente
--drop table TbDeadPedido

-- Populando as tabelas
insert into TbDeadCliente values ('Tiririca', 'Rua do Falcão, 76 - Majordisneylandia - Fortaleza')
insert into TbDeadCliente values ('Falcão', 'Rua do Adamastor, 24 - Testejana - Fortaleza')
insert into TbDeadCliente values ('Adamastor', 'Rua do Tiririca, 48 - Testelandia - Fortaleza')
insert into TbDeadCliente values ('Barnabé', 'Rua da Rosiclea')
insert into TbDeadCliente values ('Rosiclea', 'Rua do Barnabé')

insert into TbDeadPedido values ('Falcão', 'Rua do Adamastor, 24 - Testejana - Fortaleza')
insert into TbDeadPedido values ('Adamastor', 'Rua do Tiririca, 48 - Testelandia - Fortaleza')

-- Visualizar os dados das tabelas
select * from TbDeadCliente
select * from TbDeadPedido


-- Criando as procedures para simulação
CREATE PROCEDURE sp_Atualiza1
AS
begin transaction 
	update	TbDeadCliente
	set		EndCliente = 'Rua da Rosiclea, 56A - SeiLáOnde - São Paulo'
	where	CdDeadCliente = 4

	waitfor delay '00:00:05'

	update	TbDeadPedido
	set		EndClientePedido = 'Rua do Tiririca, 48 - Uruarubina - Fortaleza'
	where	CdDeadPedido = 2

	waitfor delay '00:00:05'
rollback
go

CREATE PROCEDURE sp_Atualiza2
as
begin transaction 
	update	TbDeadPedido 
	set		EndClientePedido = 'Rua do Tiririca, 48 - Uruarubina - Fortaleza'
	where	CdDeadPedido = 2
	
	waitfor delay '00:00:05'

	update	TbDeadCliente
	set		EndCliente = 'Rua da Rosiclea, 56A - SeiLáOnde - São Paulo'
	where	CdDeadCliente = 4

	waitfor delay '00:00:05'
rollback

--------------------------
-- Causando o DEAD LOCK --
--------------------------
-- 1. Execute a sp_Atualiza1 em uma sessão;
-- - EXECUTE sp_Atualiza1

-- 2. Logo em seguida, execute a sp_Atualiza2 em uma outra sessão;
-- - EXECUTE sp_Atualiza2

----------------------------------
-- Mensagem de erro de deadlock --
----------------------------------
-- (1 row(s) affected)
-- Msg 1205, Level 13, State 51, Procedure sp_Atualiza2, Line 11
-- A transação (ID do processo 72) entrou em deadlock em bloquear recursos com outro processo e foi escolhida como a vítima do deadlock. Execute a transação novamente.

-- 3. Monitore via SQL Profiler caso queiram ver maiores detalhes...