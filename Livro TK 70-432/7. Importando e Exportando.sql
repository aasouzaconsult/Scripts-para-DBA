-- No Prompt de comando...
-- Exportando dados formato de caractere (-c)
bcp AdventureWorks.HumanResources.Department out D:\Alex\Temp\departament.txt -c -S AAS\SQL2008 -T

-- Exportando dados formato de caractere (-c)
bcp AdventureWorks.HumanResources.Department out D:\Alex\Temp\departament_n.txt -n -S AAS\SQL2008 -T

SELECT * FROM AdventureWorks.HumanResources.Department

--Importando e Exportando dados