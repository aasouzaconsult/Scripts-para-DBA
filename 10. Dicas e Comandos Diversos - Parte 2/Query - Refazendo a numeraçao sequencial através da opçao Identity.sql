/*	Muitas vezes temos a necessidade de criar uma seqüência númerica de valores de forma automática. 
	O SQL Server fornece esta funcionalidade através da opção Identity que pode ser configurada para 
um campo dentro de uma table.
	Mas caso seja necessário alterar esta seqüência numérica já existe mantendo os dados já existentes,
o SQL Server também consegui fazer este gerenciamento de valores tranquilamente, mas caso o servidor 
seja reinicializada o valor Identity definido para a coluna é reinicializado, ou seja, caso o último 
valor identity gerado seja o número 10, após a reinicialização do servidor este valor será reinicializado 
para o número 1.
	Justamente por este motivo, o script a seguir permite melhorar esta lógica, possibilitando mantêr 
este valor sequencial sempre atualizado, veja abaixo o código de exemplo: */ 

-- Para desativar a propriedade identity na table desejada: 
SET IDENTITY_INSERT NomedaTable Off
 
-- Para ativar a propriedade identity na table desejada: 
SET IDENTITY_INSERT NomedaTable On

Declare @Identity Int
---Refazendo numeração Controle de Entrada - Matéria Prima ---
Set @Identity=(Select Ident_Current('CTEntrada_PQC'))
DBCC CheckIdent('CTEntrada_PQC',Reseed,@Identity)

---Refazendo numeração Controle de Produção - Moinho ---
Set @Identity=(Select Ident_Current('CTProducao_Moinho'))
DBCC CheckIdent('CTProducao_Moinho',Reseed,@Identity)

---Refazendo numeração Controle de Entrada - Recebimento - Látex ---
Set @Identity=(Select Ident_Current('CTEntrada_Recebimento_Látex'))
DBCC CheckIdent('CTEntrada_Recebimento_Latatex',Reseed,@Identity)

---Refazendo numeração Controle de Produção - PVM ---
Set @Identity=(Select Ident_Current('CTProducao_PVM'))
DBCC CheckIdent('CTProducao_PVM',Reseed,@Identity)