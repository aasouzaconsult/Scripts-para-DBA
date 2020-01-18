#
# Verifica a data do ultimo backup dos databases
#
clear

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
$s = New-Object ('Microsoft.SqlServer.Management.Smo.Server') "OTISRUSH" 

$dbs=$s.Databases

# Recupera a ultima data de backup - Backup Full e Backup do log 
#
$dbs | SELECT Name,LastBackupDate, LastLogBackupDate | Format-Table -autosize 

