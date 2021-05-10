-- создадим таблицу

CREATE TABLE dbo.TestTrace(
				name ntext NULL,
				timestamp datetime NULL,
				cpu_time bigint NULL,
				database_id int NULL,
				database_name ntext NULL,
				duration bigint NULL,
				logical_reads bigint NULL,
				physical_reads bigint NULL,
				row_count bigint NULL,
				sql_text ntext NULL,
				statement ntext NULL,
				writes bigint NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];

 

-- загрузка данных трассировки в таблицу для ms sql 2012+

INSERT INTO dbo.TestTrace(name, timestamp, cpu_time, database_id, database_name, duration, logical_reads, physical_reads, row_count, sql_text, statement, writes)
SELECT
	name AS name,
	timestamp AS timestamp,
	cpu_time as cpu_time,
	database_id as database_id,
	database_name as database_name,
	duration as duration,
	logical_reads as logical_reads,
	physical_reads as physical_reads,
	row_count as row_count,
	sql_text as sql_text,
	statement as statement,
	writes as writes
FROM (
	SELECT
		event_data.value('(event/@name)[1]', 'nvarchar(max)') AS name,
		event_data.value('(event/@timestamp)[1]', 'datetime') AS timestamp,
		event_data.value('(event/data[@name="cpu_time"])[1]', 'bigint') AS cpu_time,
		event_data.value('(event/data[@name="database_id"])[1]', 'int') AS database_id,
		event_data.value('(event/data[@name="database_name"])[1]', 'nvarchar(max)') AS database_name,
		event_data.value('(event/data[@name="duration"])[1]', 'bigint') AS duration,
		event_data.value('(event/data[@name="logical_reads"])[1]', 'bigint') AS logical_reads,
		event_data.value('(event/data[@name="physical_reads"])[1]', 'bigint') AS physical_reads,
		event_data.value('(event/data[@name="row_count"])[1]', 'bigint') AS row_count,
		event_data.value('(event/data[@name="sql_text"])[1]', 'nvarchar(max)') AS sql_text,
		event_data.value('(event/data[@name="statement"])[1]', 'nvarchar(max)') AS statement,
		event_data.value('(event/data[@name="writes"])[1]', 'bigint') AS writes

	FROM (
		SELECT 
			CAST(event_data AS XML) AS event_data
		FROM sys.fn_xe_file_target_read_file('E:\tmp\Ивацевичи\2021_05_07\*.xel', null, null, null)
		) xel
	) AS rawData
WHERE
	name IS NOT NULL;