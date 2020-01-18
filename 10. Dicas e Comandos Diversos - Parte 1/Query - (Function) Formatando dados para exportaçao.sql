/*
	Formatando dados para exportação
	Quando temos que exportar dados para sistemas de terceiros ou outras empresas, algumas regras 
são impostas (layout). A mais comum é enviar campos numéricos com zeros à esquerda e espaços 
em branco a direita dos campos string.
	Segue abaixo exemplo de duas funções (FC) para formatação desses tipos de campos. 
*/

create function f_dba_ad_espaco(@campo varchar(200), @tamanho int)
returns varchar(200)
as
begin
return left(@campo + replicate(' ',@tamanho), @tamanho)
end


create function f_dba_ad_zeros(@campo varchar(200), @tamanho int)
returns varchar(200)
as
begin
return right(replicate('0',@tamanho) + replace(@campo,' ',''), @tamanho)
end

/* Para testar as funções acima podemos utilizar o utilitário BCP do MS SQL Server, executado direto do 
“MS SQL Server Management Studio”.
   A partir da versão 2005 tempos que habilitar a execução do “XP_cmdshell”. */

exec sp_configure 'show advanced options',1
reconfigure
go

exec sp_configure 'xp_cmdshell',1
exec sp_configure 'show advanced options',0
reconfigure
go


----------------------------------------------------------------------
-- Exemplo
----------------------------------------------------------------------
select dbo.f_dba_ad_espaco('Tulio Rosa',30) + dbo.f_dba_ad_zeros(123,10) as arq
into ##temp

select * from ##temp


----------------------------------------------------------------------
-- Gera o arquivo texto
----------------------------------------------------------------------
declare @dir_arquivo nvarchar(500)
declare @exec nvarchar(1000)
declare @test_exec bit

set @dir_arquivo = 'k:\teste.txt'

set @exec = 'bcp "select arq from ##temp" queryout ' + @dir_arquivo + ' -r \n -Snomeservidor -Uusuario -Psenha -c -C raw'
exec @test_exec = master..xp_cmdshell @exec

if @test_exec <> 0 raiserror ('Erro na geracao do arquivo!', 16,1)


/*	Identificando espaços em branco dentro de um campo cararacter
Como realizar a verificação para identificar a existência de espaços em branco contidos dentro de um 
campo char, varchar, nvarchar, nchar. Veja abaixo o código de exemplo: */ 
SELECT	
		<Campo>
,	CASE WHEN CharIndex(' ',<Campo>,1)=0 
		THEN 'Não Tem' 
	ELSE	 'Tem'
    END
FROM	<Tabela>