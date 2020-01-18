DELETE	Top (10000000)
   FROM  TbLgh
WHERE  DhLgh < Convert(varchar, getdate() - 180, 112) -- 6 Meses

UPDATE STATISTICS [dbo].[TbLgh]

ALTER INDEX ALL	ON TbLgh REBUILD