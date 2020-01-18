Declare @Comando Varchar(1000),  
               @Ano Int

Set @Ano=2011   

While @Ano <=2039
 Begin
  If @Ano <> 2020 
   Begin
    Set @Comando='CREATE TABLE [dbo].[PRODUTOS'+CONVERT(Char(4),@Ano)+']
                              ([CODIGO] [int] NOT NULL,
	                           [DESCRICAO] [varchar](100) NULL,
	                           [DATA] [date] DEFAULT GETDATE(),
                               PRIMARY KEY CLUSTERED ([CODIGO] ASC)
                               WITH (PAD_INDEX  = OFF, 
                               STATISTICS_NORECOMPUTE  = OFF, 
                               IGNORE_DUP_KEY = OFF, 
                               ALLOW_ROW_LOCKS  = ON,
                               ALLOW_PAGE_LOCKS  = ON) 
                               ON [PRIMARY]) 
                               ON [PRIMARY]'
                                 
    Exec(@Comando)   
       
    Set @Ano=@Ano+1  
  
  End 
  Else
     Set @Ano=@Ano+1      
 End  