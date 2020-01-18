ECHO OFF
 ECHO ************************************************************
 ECHO ***** Compactar arquivo e movendo para local de backup *****
 ECHO ************************************************************
 ECHO.
 ECHO Efetuando compactação de arquivo....
 ECHO.
	C:\Arquiv~1\WinRAR\WinRAR.exe a -df "D:\BackupBD\TopManager\TopManager_backup_%date:~6,4%%date:~3,2%%date:~0,2%.rar" "D:\BackupBD\TopManager\TopManager_backup_*2300.bak"
 ECHO.
 ECHO ************************************************************
 ECHO *****          Arquivo compactado com sucesso!         *****
 ECHO ************************************************************
 ECHO.
ECHO ON
 
 