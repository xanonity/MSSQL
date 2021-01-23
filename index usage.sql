SELECT DB_NAME(database_id) as database_name, 
OBJECT_NAME(s.object_id) as object_name, i.name, s.* 
FROM sys.dm_db_index_usage_stats s 
	join sys.indexes i
		ON s.object_id = i.object_id 
		AND s.index_id = i.index_id  
		--and s.object_id = object_id('dbo.DataFile')