BEGIN -- подготовка
IF OBJECT_ID('tempdb..#v_indexes') IS NOT NULL
	DROP TABLE #v_indexes;
IF OBJECT_ID('tempdb..#v_indexes_usage_stats') IS NOT NULL
	DROP TABLE #v_indexes_usage_stats;
;WITH v_indexes AS (
select 	
		SCHEMA_ID(OBJECT_SCHEMA_NAME(ix.object_id,DB_ID())) as [schema_id],		
		OBJECT_SCHEMA_NAME(ix.object_id,DB_ID()) as [schema_name],
		ix.object_id as [object_id],
		OBJECT_NAME(ix.object_id) as [object_name],
		ix.index_id as [index_id],
		ix.Name as [index_name],
		ix.type,
		ix.type_desc,
		ix.is_unique,
		ix.data_space_id,
		case ds.type
			when 'FG' then ds.name
			when 'PS' then (select distinct name from sys.partition_schemes where data_space_id = ix.data_space_id)
		end as data_space,
		isnull((select fanout from sys.partition_functions prtfn
									join sys.partition_schemes as prtsch on prtfn.function_id = prtsch.function_id
									where prtsch.data_space_id =  ix.data_space_id),0) as part_count,
		ix.ignore_dup_key,
		ix.is_primary_key,
		ix.is_unique_constraint,
		ix.fill_factor,
		ix.is_padded,
		ix.is_disabled,
		ix.is_hypothetical,		
		ix.allow_row_locks,
		ix.allow_page_locks,
		ix.filter_definition
from sys.indexes as ix
join sys.data_spaces as ds on ds.data_space_id = ix.data_space_id
)
SELECT *
INTO #v_indexes
FROM v_indexes;

WITH v_indexes_usage_stats AS 
(select 
		ix.schema_id,		
		ix.schema_name,
		ix.object_id,
		ix.object_name,
		ix.index_id,
		ix.index_name,
		ix.type,
		ix.type_desc,
		ix.is_unique,
		ix.data_space_id,
		ix.data_space,
		ix.part_count,
		ix.ignore_dup_key,
		ix.is_primary_key,
		ix.is_unique_constraint,
		ix.fill_factor,
		ix.is_padded,
		ix.is_disabled,
		ix.is_hypothetical,		
		ix.allow_row_locks,
		ix.allow_page_locks,
		ix.filter_definition,
		iu.user_seeks,
		iu.user_scans,
		iu.user_lookups,
		iu.system_seeks,
		iu.system_scans,
		iu.system_lookups	
from #v_indexes as ix
join sys.dm_db_index_usage_stats as iu on iu.index_id = ix.index_id and iu.object_id = ix.object_id and iu.database_id = DB_ID()
)
SELECT *
INTO #v_indexes_usage_stats
FROM v_indexes_usage_stats
END
GO
-- список индексов, по которым нет статистики
SELECT  'Нет статистики' AS [Tables],
	 quotename(i.schema_name)+'.'+quotename(i.object_name) as [object], 
	 i.index_id, quotename(i.index_name) as index_name, 
	 i.type_desc, i.data_space, i.part_count,si.rowcnt,'DROP INDEX '+QUOTENAME(i.index_name)+' ON '+QUOTENAME(i.schema_name)+'.'+QUOTENAME(i.object_name)
FROM #v_indexes i
inner join sys.sysindexes si on si.id = i.object_id and si.indid = i.index_id
where schema_name not in ('sys','dbatools') 
	 and not exists(select * from #v_indexes_usage_stats  
						  where object_id = i.object_id and index_id = i.index_id)
	 and i.is_primary_key = 0 and is_unique = 0 and index_id > 0
order by object_name,index_id
go

-- список неиспользуемых индексов
select  'Не использованные индексы' AS [Tables],
	 quotename(i.schema_name)+'.'+quotename(i.object_name) as [object], 
	 i.index_id, quotename(i.index_name) as index_name, 
	 i.type_desc, i.data_space, i.part_count,si.rowcnt, i.user_lookups,i.is_disabled,
	 'DROP INDEX '+QUOTENAME(i.index_name)+' ON '+QUOTENAME(i.schema_name)+'.'+QUOTENAME(i.object_name)
from #v_indexes_usage_stats i
inner join sys.sysindexes si on si.id = i.object_id and si.indid = i.index_id
where schema_name not in ('sys','dbatools') 
	 and i.is_primary_key = 0 and is_unique = 0
	 and user_seeks = 0 and user_scans = 0 and index_id > 0 
order by object_name,index_id
go

-- Детальная статистика по индексам (выбранные таблицы)
select 'Детальная статистика по индексам' AS [Tables], quotename(schema_name)+'.'+quotename(object_name) as [object],
		  quotename(index_name) as index_name,type_desc,si.rowcnt,
		  user_seeks,user_scans,user_lookups,is_unique,data_space,part_count		  
from #v_indexes_usage_stats s
	 inner join sys.sysindexes si on si.id = s.object_id and si.indid = s.index_id
where	  schema_name not in ('dbatools','sys') and index_id > 0 
		  and is_disabled = 0
		  and object_name in ('FinInstruments') -- таблица
order by s.object_name,s.user_seeks desc,s.user_scans desc
GO

-- Индексы вызывающие издержки
SELECT TOP 100 'Индексы вызывающие издержки' AS [Tables],
       [Total Cost] = ROUND(avg_total_user_cost * avg_user_impact * (user_seeks + user_scans),0),
       avg_user_impact,
       TableName = statement,
       [EqualityUsage] = equality_columns,
       [InequalityUsage] = inequality_columns,
       [Include Cloumns] = included_columns,
       s.user_seeks,
       s.user_scans,
       s.last_user_seek,
       s.last_user_scan
  FROM sys.dm_db_missing_index_groups g 
  INNER JOIN sys.dm_db_missing_index_group_stats s ON s.group_handle = g.index_group_handle 
  INNER JOIN sys.dm_db_missing_index_details d ON d.index_handle = g.index_handle
   WHERE database_id = DB_ID() and user_seeks >5 --and last_user_seek >= '20130301' 
  ORDER BY  [statement], s.user_seeks desc


  