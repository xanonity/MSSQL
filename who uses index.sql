SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
DECLARE @IndexName AS NVARCHAR(128) = 'IX_DataFile_Id_DirId_Active_Name';

-- Make sure the name passed is appropriately quoted 
IF (LEFT(@IndexName, 1) <> '[' AND RIGHT(@IndexName, 1) <> ']') SET @IndexName = QUOTENAME(@IndexName); 
--Handle the case where the left or right was quoted manually but not the opposite side 
IF LEFT(@IndexName, 1) <> '[' SET @IndexName = '['+@IndexName; 
IF RIGHT(@IndexName, 1) <> ']' SET @IndexName = @IndexName + ']';

-- Dig into the plan cache and find all plans using this index 
;WITH XMLNAMESPACES 
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')    
SELECT 
stmt.value('(@StatementText)[1]', 'varchar(max)') AS SQL_Text, 
obj.value('(@Database)[1]', 'varchar(128)') AS DatabaseName, 
obj.value('(@Schema)[1]', 'varchar(128)') AS SchemaName, 
obj.value('(@Table)[1]', 'varchar(128)') AS TableName, 
obj.value('(@Index)[1]', 'varchar(128)') AS IndexName, 
obj.value('(@IndexKind)[1]', 'varchar(128)') AS IndexKind, 
cp.plan_handle, 
query_plan 
FROM sys.dm_exec_cached_plans AS cp 
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp 
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS batch(stmt) 
CROSS APPLY stmt.nodes('.//IndexScan/Object[@Index=sql:variable("@IndexName")]') AS idx(obj) 
OPTION(MAXDOP 1, RECOMPILE);

WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT
	DB_NAME(E.dbid) AS [DBName],
	object_name(E.objectid, dbid) AS [ObjectName],
	P.cacheobjtype AS [CacheObjType],
	P.objtype AS [ObjType],
	E.query_plan.query('count(//RelOp[@LogicalOp = ''Index Scan'' or @LogicalOp = ''Clustered Index Scan'']/*/Object[@Index=sql:variable("@IndexName")])') AS [ScanCount],
	E.query_plan.query('count(//RelOp[@LogicalOp = ''Index Seek'' or @LogicalOp = ''Clustered Index Seek'']/*/Object[@Index=sql:variable("@IndexName")])') AS [SeekCount],
	E.query_plan.query('count(//Update/Object[@Index=sql:variable("@IndexName")])') AS [UpdateCount],
	P.refcounts AS [RefCounts],
	P.usecounts AS [UseCounts],
	E.query_plan AS [QueryPlan]
FROM sys.dm_exec_cached_plans P
CROSS APPLY sys.dm_exec_query_plan(P.plan_handle) E
WHERE	
	E.query_plan.exist('//*[@Index=sql:variable("@IndexName")]') = 1