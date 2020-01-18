--
-- Extended Stored Procedure não documentada: xp_fixeddrives
 
EXEC xp_fixeddrives 


-- Em Powershell...
-- 
gwmi Win32_LogicalDisk | ft DeviceId,@{e={$_.FreeSpace/1GB};l="FreeSpace GB"} -a

