#
# Select usando Powershell
#
Invoke-Sqlcmd -Query "SELECT TOP 30 nome, continente FROM DB_Mundo.dbo.Paises" -Serverinstance "OtisRush"