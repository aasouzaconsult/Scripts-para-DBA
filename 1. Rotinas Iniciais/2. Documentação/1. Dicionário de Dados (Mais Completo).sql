-- Dicionário de Dados
-- Por: Antonio Alex

Select
	tabelas.type_desc as 'Tipo Tabela'
,	tabelas.create_date as 'Criado em'
,	tabelas.name as 'Tabela'
,	colunas.name as 'Coluna'
,	tipos.name as 'Tipo'
,	colunas.max_length as 'Tamanho'
,	'Aceita Nulo ?' =	Case When (colunas.is_nullable = 1)
							Then 'Sim'
						Else
							'Não'
						End
,	is_identity =	Case When (colunas.is_identity = 1)
						Then 'Sim'
					Else
						'Não'
					End
,	colunas.collation_name
--,	indices.name as 'Indice'
--,	indices.type_desc as 'Tipo de Indice'
from	sys.tables	tabelas
join	sys.columns colunas on colunas.object_id = tabelas.object_id
join	sys.types	tipos	on tipos.system_type_id = colunas.system_type_id
--join	sys.indexes indices on indices.object_id = colunas.object_id
order by
	tabelas.name
,	colunas.name

--select * from sys.tables -- object_id (ID da Tabela)
--select * from sys.foreign_keys -- parent_object_id (ID da Tabela)
--select * from sys.foreign_key_columns -- parent_object_id (ID da Tabela)