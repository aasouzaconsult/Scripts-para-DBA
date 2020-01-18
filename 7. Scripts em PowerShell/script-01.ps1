#
# Dispara JObs.
# No exemplo dispara JObs que começam por "Backup"
#
# Servidor: OTISRUSH
# Instancia: DEFAULT
#
cls

DIR SQLSERVER:\SQL\OTISRUSH\DEFAULT\JobServer\Jobs\Backup* | % {$_.Start()}

"Executou os Jobs"