#
# Restaura o database
#
cls

# carrega assemblies
#
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null

# É necessario carregar SmoExtended para backup
#
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null

# Pegar o noem do arquivo de backup e salvar na variavel
#
#
$backupFile = "C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\Backup\DB_Mundo_20100220144237.bak"

# Consultando o nome do database do ultimo backup realizado

$server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") "(local)"
$backupDevice = New-Object ("Microsoft.SqlServer.Management.Smo.BackupDeviceItem") ($backupFile, "File")
$smoRestore = new-object("Microsoft.SqlServer.Management.Smo.Restore")

# Acertando para o restore...
#
$smoRestore.NoRecovery = $false;
$smoRestore.ReplaceDatabase = $true;
$smoRestore.Action = "Database"

# Apresenta contador na tela a cada 5% de progress0
#
$smoRestore.PercentCompleteNotification = 5;

$smoRestore.Devices.Add($backupDevice)

# Le o nome do database no cabecalho do arquivo de backup
#
$smoRestoreDetails = $smoRestore.ReadBackupHeader($server)

# Mostra na tela o nome do database
#
"Database Name : " + $smoRestoreDetails.Rows[0]["DatabaseName"]

$smoRestore.Database = $smoRestoreDetails.Rows[0]["DatabaseName"]

# processo de restore
#
$smoRestore.SqlRestore($server)

"Feito - Restaurado o database" 
