-- Ativando Recursos Avançados
sp_configure 'show advanced options', 1; 
GO
RECONFIGURE;
 
-- Habilitando o Database Mail
sp_configure 'Database Mail XPs', 1
GO
RECONFIGURE WITH OVERRIDE
GO

-- Vendo as Configurações Geral do Servidor
sp_configure

-- Configurando --> Ver Arquivo:
-- D:\Alex\SQL Server\Certificação SQL Server 2008\Projetos_Querys\ProjetoEstudos\Querys\Database Mail (Configurando).pptx
