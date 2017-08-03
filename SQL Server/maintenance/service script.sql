select * from dbatools.v_show_free_spacedata_all
--alter database ut1gl set recovery simple
dbcc shrinkfile(2,15000)
go
-- »ндексы
select * from dbatools.fn_cluster_index_for_smart_rebuild(8,1000000000,10.00) i
go
select * from dbatools.fn_index_for_smart_rebuild(8,1000000000,10.00) i
go

exec dbatools.sp_clear_expired_smart_reindex
go

exec dbatools.sp_smart_cluster_reindex	@min_page_count = 8, 
										@max_page_count=9223372036854775807,
										@avg_per = 10.00,
										@debug_info = 1
go

exec dbatools.sp_smart_reindex 	@min_page_count = 8, 
								@max_page_count=9223372036854775807,
								@avg_per = 10.00,
								@debug_info = 1,
								@is_online=1
go

exec sp_updatestats
go

select * from dbatools.rep_service_index
order by start_time desc
go

select * from dbatools.v_date_diff_last_smart_reindex
go

delete from dbatools.rep_service_index
go

select * from dbatools.v_indexes i
where 
	schema_name not in ('sys','dbatools')
and	data_space = 'PRIMARY'
and index_id > 1

-- список индексов, по которым нет статистики
select  
	 quotename(i.schema_name)+'.'+quotename(i.object_name) as [object], 
	 i.index_id, quotename(i.index_name) as index_name, 
	 i.type_desc, i.data_space, i.part_count,si.rowcnt,'DROP INDEX '+QUOTENAME(i.index_name)+' ON '+QUOTENAME(i.object_name)
FROM dbatools.v_indexes i
inner join sys.sysindexes si on si.id = i.object_id and si.indid = i.index_id
where schema_name not in ('sys','dbatools') 
	 and not exists(select * from dbatools.v_indexes_usage_stats  
						  where object_id = i.object_id and index_id = i.index_id)
	 and i.is_primary_key = 0 and is_unique = 0 and index_id > 0
order by object_name,index_id
go

-- список неиспользуемых индексов
select  
	 quotename(i.schema_name)+'.'+quotename(i.object_name) as [object], 
	 i.index_id, quotename(i.index_name) as index_name, 
	 i.type_desc, i.data_space, i.part_count,si.rowcnt, i.user_lookups,i.is_disabled,
	 'DROP INDEX '+QUOTENAME(i.index_name)+' ON '+QUOTENAME(i.object_name)
from dbatools.v_indexes_usage_stats i
inner join sys.sysindexes si on si.id = i.object_id and si.indid = i.index_id
where schema_name not in ('sys','dbatools') 
	 and i.is_primary_key = 0 and is_unique = 0
	 and user_seeks = 0 and user_scans = 0 and index_id > 0 
order by object_name,index_id
go

-- ƒетальна¤ статистика по индексам (выбранные таблицы)
select  quotename(schema_name)+'.'+quotename(object_name) as [object],
		  quotename(index_name) as index_name,type_desc,si.rowcnt,
		  user_seeks,user_scans,user_lookups,is_unique,data_space,part_count		  
from dbatools.v_indexes_usage_stats s
	 inner join sys.sysindexes si on si.id = s.object_id and si.indid = s.index_id
where	  schema_name not in ('dbatools','sys') and index_id > 0 
		  and is_disabled = 0
		  and object_name in ('PreTransferConsumers') -- таблица
order by s.object_name,s.user_seeks desc,s.user_scans desc
GO

-- »ндексы вызывающие издержки
SELECT TOP 100 
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
  ORDER BY s.last_user_seek DESC

  WHERE database_id = DB_ID() and user_seeks >5 --and last_user_seek >= '20130301' 
  ORDER BY  [statement], s.user_seeks desc

  SELECT r.*,p.*
  FROM sys.dm_exec_query_stats r
  CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) p
