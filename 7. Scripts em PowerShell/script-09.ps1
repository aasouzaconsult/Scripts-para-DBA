#
# Gera Script para recriar o banco de dados fornecido
#
# Modo de utilizacao: ./script09.ps1 servidor database <c:\backup\>
#
param
(
  [string] $SQLServername,
  [string] $Databasename,
  [string] $filepath
)

[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null

$MyScripter=New-Object ("Microsoft.SqlServer.Management.Smo.Scripter")

$srv=New-Object "Microsoft.SqlServer.Management.Smo.Server" $SQLServername

$MyScripter.Server=$srv

$scrcontent=$MyScripter.Script($srv.databases["$Databasename"])

$date=Get-Date

$suffix="_"+$date.year.tostring()+"_"+$date.month.tostring()+"_" +$date.day.tostring()

$filepath=$filepath+$databasename+"_db_"+$suffix+".sql"

$scrcontent2="use [master]"+"`r`n"+"Go"+"`r`n"

foreach ($str in $scrcontent)
   {
         $scrcontent2=$scrcontent2+ $str+"`r`n"+"Go"+"`r`n"
   }
Out-File -inputobject $scrcontent2 -filepath $filepath -encoding "Default"