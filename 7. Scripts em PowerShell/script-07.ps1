#
# Primeiro criar a stored procedure
#
# USE DB_MUNDO
# GO
# CREATE PROCEDURE dbo.ListaCidades
# AS
# BEGIN
#	SET NOCOUNT ON
#	SELECT populacao,nome FROM dbo.Cidades where nome = 'Rio de Janeiro'
# END

# Executar a stored procedure
#
#	EXEC DB_Mundo.dbo.ListaCidades;
#

# agora executando a stored procedure a partir do powershell
#
#
CLS

invoke-sqlcmd -query "exec dbo.ListaCidades" -database DB_Mundo -serverinstance localhost