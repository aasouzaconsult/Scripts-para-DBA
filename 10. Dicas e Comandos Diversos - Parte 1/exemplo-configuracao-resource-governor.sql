---DMV's Resource Governor
SELECT * FROM SYS.DM_RESOURCE_GOVERNOR_WORKLOAD_GROUPS
SELECT * FROM SYS.DM_RESOURCE_GOVERNOR_RESOURCE_POOLS
SELECT * FROM SYS.DM_RESOURCE_GOVERNOR_CONFIGURATION

--Criando os Pools
CREATE RESOURCE POOL PoolMarketingAdHoc
CREATE RESOURCE POOL PoolVP

--Criando Grupos de WorkLoad
CREATE WORKLOAD GROUP GroupMarketing Using PoolMarketingAdHoc

CREATE WORKLOAD GROUP GroupAdHoc Using PoolMarketingAdHoc

CREATE WORKLOAD GROUP GroupVP Using PoolVP
Go

--Criando logins para separar os usuários dentro de diferentes grupos
CREATE LOGIN UserMarketing With Password = 'UserMarketingPwd', Check_Policy = Off
CREATE LOGIN UserAdHoc With Password = 'UserAdHocPWD', Check_Policy = Off
CREATE LOGIN UserVP With Password = 'UserVPPwd', Check_Policy = Off

--Criando Function para gerenciamento do pool
Create FUNCTION [dbo].[Classifier_ConectionPool]() 
RETURNS SYSNAME 
WITH SCHEMABINDING

BEGIN

 DECLARE @WorkGrupo VarChar(32)
 SET @WorkGrupo = 'default'
 
 If 'UserVP' = SUSER_SNAME()
  SET @WorkGrupo = 'GroupVP'
 Else If 'UserMarketing' = SUSER_SNAME()
  SET @WorkGrupo = 'GroupMarketing'
 Else If 'UserAdHoc' = SUSER_SNAME()
  SET @WorkGrupo = 'GroupAdHoc'
 RETURN @WorkGrupo
End
Go

--Alterando a configuração do Resource Governor
Alter Resource Governor
With (Classifier_Function = dbo.classifier_conectionpool)
Go

--Aplicando as reconfigurações no Resource Governor
Alter Resource Governor Reconfigure
Go
