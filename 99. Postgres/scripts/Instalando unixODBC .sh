Instalando unixODBC  
 yum install unixODBC
 
Instalando freetds 
 yum install freetds

Editando odbc.ini 
 vim /etc/odbc.ini
   Acrentar no arquivo
        [dsn_Top]
		Driver=/usr/lib64/libtdsodbc.so.0.0.0
		Server=rgsynbd
		Database=topmanager
		Port=1433
		tds_version=8.0   

Editando odbc.ini 		
 vim /etc/freetds.conf
   Acrescentar no final do arquivo  
       [dsn_Top]
       host = rgsynbd
       port = 1433
       tds version = 8.0
   
Realizar conexão
  383  isql dsn_Top topmanager tpm