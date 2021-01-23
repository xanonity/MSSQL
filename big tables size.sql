SELECT i.[name] AS IndexName
	,SUM(s.[used_page_count]) * 8/ 1024/1024 AS IndexSizeGB
	,SUM(s.[used_page_count]) * 8/ 1024 AS IndexSizeMB
FROM sys.dm_db_partition_stats AS s
	INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
	AND s.[index_id] = i.[index_id] 
WHERE s.[object_id] = object_id('Sales.Invoices')
GROUP BY i.[name]
ORDER BY i.[name]
