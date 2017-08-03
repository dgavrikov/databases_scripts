/*распределение страниц данных, с указанием файловой группы, объекта и индекса, которые эти страницы охватывают.  */

SELECT au.allocation_unit_id
,au.type_desc
,au.total_pages
,au.used_pages
,au.data_pages
,p.index_id
,i.name AS [indexname]
,i.type_desc AS [index_type]
,fg.name AS [filegroup]
,s.name AS [schema]
,o.name AS [Object]
,o.type_desc 
,p.data_compression_desc
FROM sys.system_internals_allocation_units au
JOIN sys.partitions [p] ON [p].[partition_id] = au.[container_id]
JOIN sys.filegroups fg ON au.filegroup_id = fg.data_space_id
JOIN sys.objects o ON o.object_id = p.object_id
JOIN sys.schemas s ON s.schema_id = o.schema_id
JOIN sys.indexes i ON i.object_id = o.object_id AND i.index_id = p.index_id
WHERE o.name = 'CandlesHistory'
ORDER BY total_pages desc

