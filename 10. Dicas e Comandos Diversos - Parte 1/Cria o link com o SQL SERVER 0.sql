--Cria o link com o SQL SERVER 
Declare @nmServer  varchar(20) = 'SERVER'
Declare @UserDestino varchar(20)= 'Externo'
Declare @Pass varchar(20) = '123'
EXEC master.dbo.sp_addlinkedserver @nmserver, 
									'SQL Server'
EXEC master.dbo.sp_addlinkedsrvlogin @nmserver, 
			'False',NULL,@UserDestino,@Pass

/*
-- Cria o link com ACCESS
EXECUTE sp_addlinkedserver 'cliente', 'OLE DB Provider for Jet',
'Microsoft.Jet.OLEDB.4.0', 'C:\temp\cliente.mdb'

--Cria o link com o Excell
EXEC sp_addlinkedserver 'cliente',
   'Jet 4.0',
   'Microsoft.Jet.OLEDB.4.0',
   'c:\temp\cliente.xls',
   NULL,
   'Excel 5.0'
   
--Cria o link com o Excell2007
EXEC sp_addlinkedserver @server = 'cliente', 
@srvproduct=N'ExcelData', @provider=N'Microsoft.ACE.OLEDB.12.0', 
@datasrc=N'C:\temp\cliente.xlsx',
@provstr='EXCEL 12.0' */