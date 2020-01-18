#
# Auditando as instalações do SQL Server...
#
clear

$instance = $args[0] 
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
$serverInstance = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $instance 

Write-Host "Nome: " $serverInstance.Name
Write-Host "Edicao: " $serverInstance.Edition
Write-Host "Versão: " $serverInstance.VersionString
Write-Host "Service Pack: " $serverInstance.ProductLevel 
