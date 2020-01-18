#
# Gera Script para recriar o usuarios do banco de dados fornecido
#
# Modo de utilizacao: ./script09.ps1 servidor database <c:\backup\>
#
param
(
  [string] $ServerName,
  [string] $DatabaseName,
  [string] $filepath
)

[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
$MyScripter=New-Object("Microsoft.SqlServer.Management.Smo.Scripter")
$srv=New-Object "Microsoft.SqlServer.Management.Smo.Server" "$ServerName"
$db = $srv.Databases["$DatabaseName"]

$MyScripter.Server=$srv
$date=Get-Date
$suffix="_"+$date.year.tostring()+"_"+$date.month.tostring()+"_"+$date.day.tostring()
$filepath=$filepath+$databasename+"_user_"+$suffix+".sql"

$scrcontent="use [$databasename]"+"`r`n"+"Go"+"`r`n"
Out-File -inputobject $scrcontent -filepath $filepath -encoding "Default"

foreach ( $user in $db.Users )
{
  if ( $user.IsSystemObject -eq $false )
  {
       $spcontent=$user.script()
       Out-File -inputobject $spcontent -filepath $filepath -encoding "Default" -append
       $suffix2="`r`n"+"Go"+"`r`n"
       Out-File -inputobject $suffix2 -filepath $filepath -encoding "Default" -append
  }
}
"Gerado script para criacao de usuarios"

