# 
# Backup do database especificado
# 
$dbToBackup = "DB_Mundo"

# carregar os assemblies necessarios
#
# É preciso carregar o SqlServer.SmoExtended para usar o SMO backup no SQL Server 2008
#
#
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null

cls

# Criar um novo objeto "server"
#
$server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") "(local)"
$backupDirectory = $server.Settings.BackupDirectory

# Apresenta na tela o diretorio default de backup
#
"Diretorio default de backup: " + $backupDirectory

$db = $server.Databases[$dbToBackup]
$dbName = $db.Name

$timestamp = Get-Date -format yyyyMMddHHmmss
$smoBackup = New-Object ("Microsoft.SqlServer.Management.Smo.Backup")

# BackupActionType specifica o tipo de backup.
# Opções: Database, Files ou Log
#
$smoBackup.Action = "Database"
$smoBackup.BackupSetDescription = "Backup Full de " + $dbName
$smoBackup.BackupSetName = $dbName + " Backup"
$smoBackup.Database = $dbName
$smoBackup.MediaDescription = "Disk"
$smoBackup.Devices.AddDevice($backupDirectory + "\" + $dbName + "_" + $timestamp + ".bak", "File")
$smoBackup.SqlBackup($server)

$directory = Get-ChildItem $backupDirectory

# lista somente os arquivos com extensão .bak
#
$backupFilesList = $directory | where {$_.extension -eq ".bak"}
$backupFilesList | Format-Table Name, LastWriteTime

"Backup realizado com sucesso!"