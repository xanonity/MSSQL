USE DbName  -- ������������� ������� ����
SET NOCOUNT ON; -- ��������� ����� ���������� ������������ �����, ��� ��������� ������� ���������

SET LOCK_TIMEOUT 20000 -- ����� ������ �� ����� ����������, ���� ���� �� �������� ������������

DECLARE @FragLimit float = 3.0; -- ������� � ������ ������ �������� ������������ �������
--DECLARE @Mode nvarchar(130) = 'REORGANIZE'; -- ��� ����������� ������������
DECLARE @Mode nvarchar(130) = 'REBUILD '; -- ��� ������������� ������������

DECLARE @objectid int; -- ID �������
DECLARE @indexid int; -- ID �������
DECLARE @partitioncount bigint; -- ���������� ������ ���� ������ �������������
DECLARE @schemaname nvarchar(130); -- ��� ����� � ������� ��������� �������
DECLARE @objectname nvarchar(130); -- ��� ������� 
DECLARE @indexname nvarchar(130); -- ��� �������
DECLARE @partitionnum bigint; -- ����� ������
DECLARE @frag float; -- ������� ������������ �������
DECLARE @command nvarchar(4000); -- ���������� T-SQL ��� �������������� ���� ������������

-- ����� ������ � �������� � ������� ���������� ������������� sys.dm_db_index_physical_stats
-- ����� ������ ��� �������� ������� �������� ��������� (index_id > 0), 
-- ������������ ������� ����� @FragLimit � ���������� ������� � ������� ����� 128
SELECT
    object_id AS objectid,
    index_id AS indexid,
    partition_number AS partitionnum,
    avg_fragmentation_in_percent AS frag
INTO #work_to_do
FROM sys.dm_db_index_physical_stats (DB_ID(), null, null, null, 'DETAILED')
WHERE avg_fragmentation_in_percent >= @FragLimit AND index_id > 0 AND page_count > 128;

-- ���������� ������� ��� ������ ������
DECLARE partitions CURSOR FOR SELECT * FROM #work_to_do;

-- �������� �������
OPEN partitions;

-- ���� �� �������
WHILE (1=1)
    BEGIN;
        FETCH NEXT
           FROM partitions
           INTO @objectid, @indexid, @partitionnum, @frag;
        IF @@FETCH_STATUS < 0 BREAK;
		
-- �������� ����� �������� �� ID		
        SELECT @objectname = QUOTENAME(o.name), @schemaname = QUOTENAME(s.name)
        FROM sys.objects AS o
        JOIN sys.schemas as s ON s.schema_id = o.schema_id
        WHERE o.object_id = @objectid;
        SELECT @indexname = QUOTENAME(name)
        FROM sys.indexes
        WHERE  object_id = @objectid AND index_id = @indexid;
        SELECT @partitioncount = count (*)
        FROM sys.partitions
        WHERE object_id = @objectid AND index_id = @indexid;

        SET @command = N'ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' ' + @Mode;

        IF @partitioncount > 1
            SET @command = @command + N' PARTITION=' + CAST(@partitionnum AS nvarchar(10));
		
IF @Mode = 'REORGANIZE'
	SET @command = @command + N' WITH (MAXDOP = 0)';
				
IF @Mode = 'REBUILD'
	SET @command = @command + N' WITH (MAXDOP = 0, SORT_IN_TEMPDB = ON, STATISTICS_NORECOMPUTE = ON)';	

        BEGIN TRY EXEC (@command); END TRY BEGIN CATCH END CATCH
        PRINT N'Executed: ' + @command;
    END;

-- �������� �������
CLOSE partitions;
DEALLOCATE partitions;

-- �������� ��������� �������
DROP TABLE #work_to_do;
GO
