--waitresource="PAGE: 6:3:70133"
-- database_id  = 6
-- data_file_id = 3
-- page_numer   = 70133

-- Расшифровка базы
SELECT 
    name 
FROM sys.databases 
WHERE database_id=6;

-- Расшифровка файла базы
USE DbName;
GO
SELECT 
    name, 
    physical_name
FROM sys.database_files
WHERE file_id = 3;

-- Расшифровка объекта и индекса
DBCC TRACEON(3604, -1);

--DBCC PAGE (DatabaseName, FileNumber, PageNumber, DumpStyle)
DBCC PAGE ('DbName',3,70133,2);

DBCC TRACEOFF(3604, -1);

SELECT 
    sc.name as schema_name, 
    so.name as object_name, 
    si.name as index_name
FROM sys.objects as so 
JOIN sys.indexes as si on 
    so.object_id=si.object_id
JOIN sys.schemas AS sc on 
    so.schema_id=sc.schema_id
WHERE 
    so.object_id = <ObjectID_3604>
    and si.index_id = <IndexID_3604>;
    
-- Данные на странице (медленно) 
Use DbName;
SELECT 
    sys.fn_PhysLocFormatter (%%physloc%%),
    *
FROM Sales.OrderLines (NOLOCK)
WHERE sys.fn_PhysLocFormatter (%%physloc%%) like '(3:70133%';
    
    
    
    
--waitresource="KEY: 6:72057594041991168 (ce52f92a058c)"
-- database_id = 6
-- hobt_id = 72057594041991168
-- hash = (ce52f92a058c)

-- Расшифровка базы
SELECT 
    name 
FROM sys.databases 
WHERE database_id=6;

-- Расшифровка объекта и индекса
USE DbName;
SELECT 
    sc.name as schema_name, 
    so.name as object_name, 
    si.name as index_name
FROM sys.partitions AS p
JOIN sys.objects as so on 
    p.object_id=so.object_id
JOIN sys.indexes as si on 
    p.index_id=si.index_id and 
    p.object_id=si.object_id
JOIN sys.schemas AS sc on 
    so.schema_id=sc.schema_id
WHERE hobt_id = 72057594041991168;

-- Расшифровка записи (скан)
SELECT
    *
FROM TableName (NOLOCK)
WHERE %%lockres%% = '(ce52f92a058c)';

