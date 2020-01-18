use AdventureWorks 
go
select sys.tables.name as tabela, sys.indexes.name as indice, 
		sys.indexes.type_desc as tipo , sys.indexes.fill_factor, sys.indexes.is_padded as padded
		from sys.indexes
inner join  sys.tables
on sys.indexes.object_id = sys.tables.object_id
where sys.indexes.is_disabled =0 and sys.indexes.type <> 0
order by tabela, tipo 



