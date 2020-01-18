-- Criando o Banco de Dados SQLMagazine --
Create Database SQLMagazine
Go

Use SQLMagazine
Go

Listagem 2. Criação das tabelas Revistas e RevistasCompactadas
-- Bloco 1 --
Create Table Revistas
 (Codigo SmallInt Identity(1,1) Primary Key,
  Descricao Varchar(50),
  Edicao Int Default(1),
  AnoPublicacao Int Default(2009))
 On [Primary]
Go

-- Bloco 2 --
Create Table RevistasCompactadas
 (Codigo SmallInt Identity(1,1) Primary Key,
  Descricao Varchar(50),
  Edicao Int Default(1),
  AnoPublicacao Int Default(2009))
 On [Primary] 
WITH (DATA_COMPRESSION = ROW) 
Go

Listagem 3. Inserindo dados nas tabelas Revistas e RevistasCompactadas
-- Bloco 1 --
Declare @Cont Int

Set @Cont=1

While (@Cont <= 10000)
  Begin
    Insert Into Revistas Values ('SQL Magazine',@Cont,2009)
    Set @Cont +=1;
  End
Go

-- Bloco 2 --
Declare @Cont Int

Set @Cont=1

While (@Cont <= 10000)
  Begin
    Insert Into RevistasCompactadas Values ('SQL Magazine',@Cont,2009)
    Set @Cont +=1;
  End
Go

Listagem 4. Consultando o espaço físico ocupado por cada tabela
-- Bloco 1 --
sp_spaceused 'Revistas'
Go

-- Bloco 2 --
sp_spaceused 'RevistasCompactadas'
Go


Listagem 5. Alterando o nível de compactação da tabela RevistasCompactadas
-- Bloco 1 --
Alter Table RevistasCompactadas
Rebuild With (DATA_COMPRESSION=PAGE)
Go


Listagem 6. Consultando o espaço físico ocupado por cada tabela em nível de pagina 
-- Bloco 1 --
sp_spaceused 'Revistas'
Go

-- Bloco 2 --
sp_spaceused 'RevistasCompactadas'
Go

-- Bloco 3 -- 
Select * from RevistasCompactadas
Where Edicao=69

Select * from RevistasCompactadas
Where Edicao in (66,68,70)

Listagem 7. Sintaxe da sp_estimate_data_compression_savings 
-- Bloco 1 --
sp_estimate_data_compression_savings 
       [ @schema_name = ] 'schema_name'  
     , [ @object_name = ] 'object_name' 
     , [@index_id = ] index_id 
     , [@partition_number = ] partition_number 
     , [@data_compression = ] 'data_compression' 
[;]


Listagem 8. Obtendo os resultados da estimativa de compactação em nível de linha
-- Bloco 1 –

EXEC sp_estimate_data_compression_savings 'dbo', 
'RevistasCompactadas', NULL, 
NULL, 
'ROW'

Listagem 9. Obtendo os resultados da estimativa de compactação em nível de página
-- Bloco 1 –

EXEC sp_estimate_data_compression_savings 'dbo',
'RevistasCompactadas', NULL, 
NULL, 
'PAGE'

