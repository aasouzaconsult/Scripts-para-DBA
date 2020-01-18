------------------------------------------------------------
-- Verificar qual a porta que o SQLSERVER esta utilizando --
------------------------------------------------------------
DECLARE @TcpPort VARCHAR(5)
        ,@RegKey VARCHAR(100)

IF @@SERVICENAME !='MSSQLSERVER'
    BEGIN
        SET @RegKey = 'SOFTWARE\Microsoft\Microsoft SQL Server\' + @@SERVICENAME + '\MSSQLServer\SuperSocketNetLib\Tcp'
    END
    ELSE
    BEGIN
        SET @RegKey = 'SOFTWARE\MICROSOFT\MSSQLSERVER\MSSQLSERVER\SUPERSOCKETNETLIB\TCP'
    END

EXEC master..xp_regread
    @rootkey = 'HKEY_LOCAL_MACHINE'
    ,@key = @RegKey
    ,@value_name = 'TcpPort'
    ,@value = @TcpPort OUTPUT

SELECT @TcpPort AS PortNumber
        ,@@SERVERNAME AS ServerName
        ,@@SERVICENAME AS ServiceName