--use locadora


--insert into TbAutor values ('Tom Cavalcante')
----update TbAutor
----set NmAutor = 'Roberto Carlos'
----where CdAutor = 10 
select 
		CdMusica
,		NmMusica
,		Convert(varchar,TempoMusica,108)
from	TbMusica

select
	NmAutor
,	Observacao =	
		case Substring (NmAutor, 1, 1)	
			when 'R' then 'Começa com ' + Substring (NmAutor, 1, 1) + '.'
			when 'T' then 'Começa com ' + Substring (NmAutor, 1, 1) + '.'
			when 'C' then 'Começa com ' + Substring (NmAutor, 1, 1) + '.'
			when 'D' then 'Começa com ' + Substring (NmAutor, 1, 1) + '.'
		else 'Teste'
		end
from TbAutor

select * from TbAutor
select * from TbCd
select * from TbGravadora
select * from TbMusica
select * from TbMusica_Autor
select * from TbMusica_CD