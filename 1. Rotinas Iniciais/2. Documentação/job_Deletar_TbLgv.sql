DELETE  FROM TbLgv
WHERE  CdLgh in ( SELECT Top 10000000 CdLgh
                                    FROM TbLgh Lgh
                                 WHERE DhLgh < Convert(varchar, getdate() - 180, 112)) -- 6 Meses
 
UPDATE STATISTICS [dbo].[TbLgv]

ALTER INDEX ALL	ON TbLgv REBUILD