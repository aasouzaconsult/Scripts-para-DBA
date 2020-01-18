SELECT T.name       AS Tabela,
	   C.name       AS Coluna,
	   TY.name      AS Tipo,
	   C.max_length AS Tamanho_Maximo, -- Tamanho em bytes, para nvarchar normalmente se divide este valor por 2
	   C.precision  AS Precisao, -- Para tipos numeric e decimal (tamanho)
	   C.scale      AS Escala -- Para tipos numeric e decimal (números após a virgula)
FROM sys.columns C
JOIN sys.tables  T  ON T.object_id     = C.object_id
JOIN sys.types   TY ON TY.user_type_id = C.user_type_id
ORDER BY T.name, C.name