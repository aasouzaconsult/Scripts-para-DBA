-- Script para diminuir o tamanho de um arquivo.
-- Este exemplo diminui o arquivo para 24MB

use Adventureworks DBCC SHRINKFILE (N'adventureworks_Data', 24)