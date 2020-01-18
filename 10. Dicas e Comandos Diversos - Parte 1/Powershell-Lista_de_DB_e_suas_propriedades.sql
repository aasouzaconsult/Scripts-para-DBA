--
-- Powershell: Lista de Databases e suas propriedades
 
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
 
$s = New-Object ('Microsoft.SqlServer.Management.Smo.Server') "LOCALHOST" 

$dbs=$s.Databases

$dbs | SELECT Name, Collation, CompatibilityLevel, AutoShrink, RecoveryModel, Size, SpaceAvailable

