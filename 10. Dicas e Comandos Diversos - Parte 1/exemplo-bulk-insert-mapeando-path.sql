USE DB_XRX_DOC
Go 

Set NoCount On 


 

 If Object_Id ('tempdb..#Documento_Teste') Is Not Null
  Drop Table #Documento_Teste

Go 
  

 Create Table #Documento_Teste 

  (  id_Doc  Int Identity (1,1) ,
     nm_Path Varchar (50) );

---=============================================================================
--  LE O DIRETORIO E INSERI TODOS OS PATHS LIDOS NA TABELA TEMPORARIO 
---=============================================================================


Insert Into  #Documento_Teste  (nm_Path) 

EXEC master..xp_cmdshell 'dir c:\teste  /b' ;---- PODE USAR AQUI UMA VARIAVEL COMO PARAMETRO DE ENTRADA DE UMA PROCEDURE 
 
---=============================================
--- APAGA REGISTROS NULOS SE TIVER  
---=============================================


 Delete From #Documento_Teste Where nm_Path Is Null ; 
 
---=============================================
--- APAGA REGISTROS NULOS SE TIVER  
---=============================================

 Declare @nm_Arquivo      Varchar(50)
 Declare @Path            Varchar(80)
 Declare @SQL             Varchar(1000)

 Set @Path = 'c:\teste\'   -- PODE USAR AQUI UMA VARIAVEL COMO PARAMETRO DE ENTRADA DE UMA PROCEDURE 


 Declare cCursor_Image Cursor  For

   Select Distinct 

          nm_Path

     From  #Documento_Teste ;


 Open  cCursor_Image 

 Fetch Next From cCursor_Image Into @nm_Arquivo 

 While @@Fetch_Status  = 0 

 Begin



Select @SQL = 'INSERT INTO Documento_Teste (nm_Path,im_Doc) ' + char(13)

Select @SQL = @SQL + 'SELECT nm_Doc = ''' +  @Path + @nm_Arquivo + ''', * '+ char(13) 
Select @SQL =  @SQL + 'FROM OPENROWSET(BULK '''+  @Path + @nm_Arquivo + ''' , SINGLE_BLOB) AS Document'

Execute ( @SQL )
--Select @SQL

Fetch Next From cCursor_Image Into @nm_Arquivo 


  End 

Close cCursor_Image
Deallocate cCursor_Image


Set NoCount Off
Go 
 

 
--  Select * From Documento_Teste
--  Truncate Table  Documento_Teste

 