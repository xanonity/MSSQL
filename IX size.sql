SELECT i.[name] AS IndexName
,object_name(s.object_id) AS TableName
,SUM(s.[used_page_count]) * 8/ 1024/1024 AS IndexSizeGB
,'ALTER INDEX ['+i.[name]+'] ON [dbo].['+object_name(s.object_id)
+'] REBUILD PARTITION = ALL 
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)'
FROM sys.dm_db_partition_stats AS s
INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
AND s.[index_id] = i.[index_id] and s.[object_id] = object_id('dbo.DataFile')
--and i.name like 'I%'
GROUP BY i.[name],s.object_id
ORDER BY IndexSizeGB desc