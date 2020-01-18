select	getdate()-7 as data
,		DATENAME(WEEKDAY, getdate()-7) as Dia
,		DATENAME(WEEK, getdate()-7) as Semana

-- Meses
SET LANGUAGE 'Brazilian'
;WITH Meses AS
(
  SELECT 1 AS IdMes, DATENAME(MONTH, 0) AS NomeMes
  UNION ALL
  SELECT IdMes + 1, DATENAME(MONTH, DATEADD(MONTH, IdMes, 0))
  FROM Meses
  WHERE IdMes < 12
)
SELECT * FROM Meses

-- Dias da Semana (Iniciando no Domingo)
SET LANGUAGE 'Brazilian'
;WITH DiaSemana AS
(
  SELECT 1 AS idDSe, DATENAME(WEEKDAY, -1) AS nomeDSe
  UNION ALL
  SELECT idDSe + 1, DATENAME(WEEKDAY, idDSe -1)
  FROM DiaSemana
  WHERE idDSe < 7
)
SELECT idDSe, nomeDSe FROM DiaSemana

-- Dias da Semana (Iniciando na Segunda)
SET LANGUAGE 'Brazilian'
;WITH DiaSemana AS
(
  SELECT 1 AS idDSe, DATENAME(WEEKDAY, 0) AS nomeDSe
  UNION ALL
  SELECT idDSe + 1, DATENAME(WEEKDAY, idDSe)
  FROM DiaSemana
  WHERE idDSe < 7
)
SELECT idDSe, nomeDSe FROM DiaSemana

