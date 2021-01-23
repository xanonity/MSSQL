SELECT SUM(st.row_count)
FROM sys.dm_db_partition_stats st
WHERE object_name(object_id) = 'GlobalFile' AND (index_id < 2)