-- Cria tabela auxiliar
IF exists (select name from tempdb..sysobjects 
	where name='tbspconfigure' and xtype='U')
DROP TABLE tempdb..tbspconfigure
CREATE TABLE tempdb..tbspconfigure
	(
		names varchar(40), 
		minimum int,	
		maximum int,
		config_value int,
		run_value int
	)
-- Carrega a tabela com o conteúdo da sp_configure
INSERT INTO tempdb..tbspconfigure exec sp_configure

select * from tempdb..tbspconfigure 
