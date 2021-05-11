-- создание функции
use Traces
go
begin try drop function fn_GetSQLNormalized end try begin catch end catch
go
create function fn_GetSQLNormalized(@TSQL nvarchar(max)) returns nvarchar(max) as  
begin 
 	declare @TmpTableName nvarchar(max) = ''  
	declare @pos int = 0 
 	set @TSQL = REPLACE ( @TSQL , 'exec sp_executesql N''' , '')  
 	set @pos = CHARINDEX(''',N''', @TSQL)
	if @pos > 0 set @TSQL = SUBSTRING(@TSQL, 1, @pos - 1)  
     	while 1=1 
		begin
			set @pos = PATINDEX('%#tt[0-9]%', @TSQL) 
			if @pos > 0 
				begin 			
					set @TmpTableName = SUBSTRING(@TSQL, @pos, LEN(@TSQL))  
					set @pos = CHARINDEX(' ', @TmpTableName)
					if @pos > 0 set @TmpTableName = SUBSTRING(@TmpTableName, 1, @pos - 1) 
					set @TSQL = REPLACE ( @TSQL , @TmpTableName , '#tt')  
				end  
			else
				break
		end  
      	return @TSQL;     
end  

-- нормализация
use Traces

go 
begin try exec('alter table MyTrace add HashSQL nvarchar(max) null') end try begin catch end catch
go

-- версия для Extended Events
update MyTrace set HashSQL = dbo.fn_GetSQLNormalized(case when statement is not null then statement when batch_text is not null then batch_text  else sql_text end)

--go 
-- версия для Profiler
--update MyTrace set HashSQL = dbo.fn_GetSQLNormalized(TextData)

-- выборка
SELECT 
      [HashSQL] AS HashSQL
      ,SUM([duration]) AS duration
      ,SUM([cpu_time]) AS cpu_time
      ,SUM([logical_reads]) AS logical_reads
      ,SUM([physical_reads]) AS Physical_reads
      ,SUM([writes]) AS Writes
      ,SUM(1) AS Executes
  FROM [Traces].[dbo].[TestTrace]
  GROUP BY [HashSQL]
  ORDER BY duration DESC


