/* Até a versão 2005 do SQL Server, para incluir registros era necessário utilizar um 
INSERT para cada registro. No SQL Server 2008 esse problema foi resolvido, permitindo
agora a inclusão de mais de um registro em um único INSERT. O exemplo abaixo demonstra 
a sua utilização: */
 
INSERT Clientes (cod, nome, endereco) VALUES
	(1, 'Alexandre Lopes', 'Quadra 1 lote 10')
,	(2, 'Kátia Rodrigues', 'Quadra 1 lote 12')
,	(3, 'Marcia Cristina', 'Quadra 2 lote 10)