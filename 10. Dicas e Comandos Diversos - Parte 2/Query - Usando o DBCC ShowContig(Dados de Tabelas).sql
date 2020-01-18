--use BDteste

create table tbRegistros (
	codigo	int identity(1,1)
,	coluna1	char(100)
,	coluna2 char(100))

select * from sys.tables

declare @cont	int
declare @total	int
set		@cont	= 0
set		@total	= 20000

while @cont < @total
begin
	insert into TbRegistros values ('ABCDEFGHIJLMNOPQRSTUVXYZ', '1234567890')
	set @cont = @cont + 1
end

-- select * from TbRegistros

dbcc showcontig