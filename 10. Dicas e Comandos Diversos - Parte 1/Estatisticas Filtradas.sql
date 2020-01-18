/*Antes de começarmos a aplicar as Estatísticas Filtradas e seus benefícios, vamos criar um novo 
ambiente para teste. Neste ambiente criaremos duas novas tabelas denominadas:Cidades e Vendas, 
conforme apresenta a Código 1.

Código 1 – Criando as tabelas Cidades e Vendas:*/
-- Criando a Tabela Cidades –
Create Table Cidades
 (Codigo Int,
   Nome VARCHAR(100),
   Estado Char(2))
Go
-- Criando a Tabela Vendas –
Create Table Vendas
  (Codigo Int,
    NumPedido Int,
    Quantidade Int)
Go
/*	Observe que ambas as tabelas possui uma estrutura simular e estão declaradas sem chaves 
primárias. 
	Agora vamos adicionar em cada tabelas os recursos de Estatísticas, que serão utilizados pelo 
SQL Server durante os processos de consulta e manipulação dos registros. Posteriormente serão 
adicionados Índices Clusterizados para cada tabela, com objetivo de melhorar os processos de busca 
de dados, além de adotar uma forma de ordenação física dos dados, conforme apresenta o Código 2.
*/
-- Código 2 – Criando Estatísticas e Índices para as Tabelas Cidades e Vendas:
-- Criando os Índices Clusterizados para Tabela Cidades
Create Clustered Index Ind_Cidades_Codigo ON Cidades(Codigo)
Go
-- Crinado um novo índice para Tabela Cidades –
Create Index Ind_Cidade_Nome ON Cidades(Nome)
Go
-- Criando novas Estatísticas para a Tabelas Cidades –
Create Statistics Sts_Cidade_Codigo_Nome ON Cidades(Codigo, Nome)
Go
-- Criando os Índices Clusterizados para Tabela Vendas –
Create Clustered Index Ind_Vendas_Codigo_NumPedido ON Vendas(Codigo,NumPedido)
Go

/*	Observe que foi adicionado somente 1 índice Clusterizado a Tabela Vendas, ao contrário da 
Tabela Cidades que adicionamos, 1 índice Clusterizado e outro índice comum, nenhum recurso ou 
mecanismo de Estátistica foi adicionado e esta tabela.
	Como nosso ambiente criado e pronto para receber nossos dados, vamos então realizar os processo 
de carga de dados, para cada tabela, conforme apresenta o Código 3.

Código 3 – Carga de dados para as Tabelas Cidades e Vendas. */

-- Inserindo dados no Tabela Cidades
Insert Cidades Values(1, 'São Roque', 'SP')
Insert Cidades Values(2, 'São Roque da Fartura', 'MG')
Go
-- Bloco para inserção de registros na Tabela Vendas
Set NoCount On
Insert Vendas Values(1, 1, 100)
Declare @Contador INT
Set @Contador = 2
While @Contador <= 1000
 Begin
  INSERT Vendas VALUES (2, @Contador, @Contador*2)
  SET @Contador +=1
End
Go

Select * from Cidades
Select * from Vendas

/* Neste momento nosso ambiente encontra-se abastecido de informações e preparado para começarmos 
a estudar um pouco mais sobre como as Estatísticas podem nos ajudar no retorno mais ágil de nossos 
dados. Para demonstrar vamos utilizar o Código 4.

Código 4 – Consultando dados armazenadas nas Tabelas Cidades e Vendas. */
-- Consultados os Dados Armazenados nas Tabelas Cidades e Vendas
SELECT		V.NumPedido 
FROM		Vendas V 
Inner Join	Cidades C On V.Codigo = C.Codigo
WHERE		C.Nome='São Roque'
OPTION (Recompile)

/*	Vamos analisar o Plano de Execução que foi incluído em nossa query e ver como esta a distribuíção 
de processamento realizado em cada operador, conforme a apresenta a Figura 1.

Figura 1 – Plano de Execução processado pelo SQL Server na execução do Código 4.

	Podemos notar que nosso Plano de Execução distribuiu a carga de processamento em cada operador 
inclusive o Nestel Loops, operador responsável em realizar a junção dos dados enviados por cada 
tabela. Este operador consumiu 21% de todo processamento realizado pelo SQL Server.*/

/* Após executarmos o Código 4, poderemos observar que mesmo existindo somente 1 registro cadastrado 
que possui venda relacionada a cidade de São Roque, o Plano de Execução estimou o retorno de 500 
linhas, conforme apresenta a Figura 2, na propriedade Estimated Number of Rows.
 
Figura 2 – Propriedades do operador Nested Loops, após a execução do Código 4.

Este comportamento nos indica que o Plano de Execução atualmente processado pelo SQL Server esta 
levando em consideração uma porção da massa de dados existente em nossa tabela Vendas, ao invês 
de tentar identificar qual realmente é a linha que possui o dados correto a ser apresentado.
Muito bem, é justamente para esta situação que podemos utilizar as Estatísticas filtradas, o que 
nos possibilitará realizar a execução da mesma query e trará ao SQL Server a possibilidade de 
aplicar um filtro sobre esta porção de dados, sem necessitarmos de qualquer tipo de alteração 
em nossa consulta, índice ou tabela.

Para criar e aplicar a estatística filtrada, utilizaremos o Código 5, apresentado a seguir: */

-- Criando novas estatísticas para as Tabela Cidades, utilizando as Estatísticas Filtradas –
CREATE STATISTICS StsFiltrada_Cidades_SaoRoque ON Cidades(Codigo)
WHERE Nome = 'São Roque'
GO
CREATE STATISTICS StsFiltrada_Cidades_Mairinque ON Cidades(Codigo)
WHERE Nome = 'Mairinque'
GO

/*	Para ilustrar e entender como nosso ambiente esta definido, a Figura 3 apresentar a Tabela 
Cidades, seus índices e estatísticas, vale destacar que as duas novas estatísticas filtradas 
adicionadas e esta tabela aparecem na mesma guia “Statitics” em conjunto com todas as outras.
 
Figura 3 – Tabela Cidades, Índices, Estatísticas e Estatísticas Filtradas.

Agora com as estas novas Estatísticas criadas em nossa Tabela Cidades, vamos executar novamente o 
Código 4, e ver qual a diferença apresentada pelo Plano de Execução ao processar mais uma vez esta 
mesma consulta.*/

-- Consultados os Dados Armazenados nas Tabelas Cidades e Vendas
SELECT		V.NumPedido 
FROM		Vendas V 
Inner Join	Cidades C On V.Codigo = C.Codigo
WHERE		C.Nome='São Roque'
OPTION (Recompile)

/*	Vamos começar novamente analisando o Plano de Execução apresentado pelo SQL Server, após a execução 
do Código 4, mas com as Estatísticas Filtradas aplicadas para a Tabela Cidades, conforme 
apresenta a Figura 4.
 
Figura 4 – Novo Plano de Execução apresentado pelo SQL Server, após executar o Código 4.

Não vamos necessitar de muitas análises para evidenciar as primeiras diferenças apresentadas 
neste novo Plano de Execução, o que nos importa é novamente observar o operador Nested Loops, 
que agora apresenta 0% de todo processamento utilizado pelo SQL Server. Com base neste valor, 
podemos entender que a carga de processamento utilizada na execução desta consulta foi dividida 
de uma forma mais inteligente entre os outros dois operadores Index Seek e Clustered Index Seek, 
onde cada um destes operadores consumiu 50% de processamento.
Estes valores nos indicam que o SQL Server conseguiu flexibilizar o processamento de nossa query, 
identificando e responsabilizando os operadores de busca e obtenção de dados em realizar todo 
processo de consulta das informações, passando de forma mais organizada para o operador Nested Loops, que simplesmente realizou a junção dos dados e enviou para o operador Select.
Com a mudança apresentada neste novo Plano de Execução, foi claro entender que o operador Nested 
Loops estava sendo utilizado de forma incorreta e consumindo recursos sem necessidade, 
principalmente na quantidade de linhas estimadas para o resultado que antes eram 500 e agora o valor 
correto é 1, a Figura 5 apresenta os novos valores aplicados ao operador Nested Loops.
 
Figura 5 – Propriedades do operador Nested Loops.

Ficou fácil e simples observar através da Figura 5, que nossa query retornou a quantidade correta 
de linhas, analisando as propriedades Actual Number Rows e Estimated Number of Row, ambas estão 
apresentando o mesmos valores, algo muito diferete do que foi apresentado anteriormente na Figura 3.
Vale ressaltar que a partir do momento que a quantidade de linhas estimadas para consulta e retorno,
os valores de Custo Estimado de CPU, Custo Estimado de I/O, Tamanho Estimado de Linhas e Custo de 
Processamento do Operador são bem menores, o que mais uma vez nos indica um ganho de performance e 
otimização no processamento de nossa query.
Após estes comparativos, chegamos ao final de nossa análise e podemos afirmar que conseguimos de uma forma bastante simples melhorar de forma sensível o processamento de nossa query, além disso, possibilitar ao SQL Server otimizar a geração do Plano de Execução utilizado para a mesma fazendo uso das Estatísticas Filtradas.
Espero que você tenha gostado de mais este artigo, que as informações apresentas aqui sobre Índices e Estatísticas possam ser
úteis no seu trabalho e estudados.

Agradeço a sua visita, até o próximo artigo.