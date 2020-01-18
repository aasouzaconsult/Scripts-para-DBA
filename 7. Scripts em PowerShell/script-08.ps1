#
# Parando o serviço do SQL Server
#
Get-Service | Where-Object {$_.Name -like "MSSQLSERVER"} | Stop-Service -Force

"Servico do SQL Server parado!"

#
# Iniciando o serviço do SQL Server (retirar comentario)
#
#####Get-Service | Where-Object {$_.Name -like "MSSQLSERVER"} | Start-Service
#
#####"Servico do SQL Server inciado!" 