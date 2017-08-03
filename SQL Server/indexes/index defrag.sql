-- »щем сильно дефрагментированные индексы и генерируем скрипт по перестройки секций.
WITH v_index AS (
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
SELECT 
	quotename(OBJECT_SCHEMA_NAME(st.object_id,st.database_id)) + '.' + quotename(object_name(st.object_id)) as obj_name,
	quotename(i.index_name) as idx_name,
	st.avg_fragmentation_in_percent,
	i.allow_page_locks,
	case ds.type
			when 'FG' then ds.name
			when 'PS' then (select distinct name from sys.partition_schemes where data_space_id = i.data_space_id)
		end as data_space,
		i.part_count as part_count,
	CASE part_count when 0 then 0 else st.partition_number end as part_number,
	st.page_count,
	i.[type],
	CASE when st.avg_fragmentation_in_percent > 30 
		then 'ALTER INDEX '+QUOTENAME(i.index_name)+' ON '+QUOTENAME(i.schema_name)+'.'+QUOTENAME(i.object_name)+' REBUILD PARTITION = '+ CASE part_count when 0 then 'ALL' else CAST(st.partition_number AS VARCHAR) end +'
GO
' 
	ELSE ''
	END AS Script
from v_index i 
INNER JOIN sys.data_spaces ds
	ON ds.data_space_id = i.data_space_id
join master.sys.dm_db_index_physical_stats(db_id(),null,null,null,'LIMITED') st on st.object_id = i.object_id and  st.index_id = i.index_id 
where 
i.is_disabled = 0 
and i.index_id > 1
and st.page_count > 8
and st.page_count <= 1000000000
and	st.avg_fragmentation_in_percent >= 50
