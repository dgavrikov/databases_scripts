select ss.name as sch_name, so.name as obj_name, dt.request_session_id
	, db_name = db.name
	, hobt_id_desc = isnull(isnull(res.res_name, res_log.res_name), so.name)
	, *
from sys.dm_tran_locks dt
	left join sys.objects so ON so.object_id = dt.resource_associated_entity_id
	left join sys.schemas ss ON ss.schema_id = so.schema_id
	left join sys.databases db on db.database_id = dt.resource_database_id
	OUTER APPLY (
		SELECT TOP 1 isnull(ss.name, '*') + '.' + isnull(o.name, '*') + '-' + isnull(i.name, '*') as res_name
						FROM sys.partitions p 
							INNER JOIN sys.objects o ON p.object_id = o.object_id
							INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id 
							INNER JOIN sys.schemas ss ON ss.schema_id = o.schema_id
						WHERE p.hobt_id = dt.resource_associated_entity_id
			) res
	OUTER APPLY (SELECT TOP 1 isnull(ss.name, '*') + '.' + isnull(o.name, '*') + '-' + isnull(i.name, '*') as res_name
						FROM ADFrontLogs.sys.partitions p 
							INNER JOIN ADFrontLogs.sys.objects o ON p.object_id = o.object_id
							INNER JOIN ADFrontLogs.sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id 
							INNER JOIN ADFrontLogs.sys.schemas ss ON ss.schema_id = o.schema_id
						WHERE p.hobt_id = dt.resource_associated_entity_id) res_log

where dt.request_session_id in (102, 308, 150) --where dt.request_session_id in (102) --where dt.request_session_id in (308) --where dt.request_session_id in (150)
	and dt.resource_database_id > 4
	and dt.resource_lock_partition = 6
	--and dt.request_status <> 'GRANT'
	--and so.type_desc IS NOT NULL
