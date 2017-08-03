-- скрипт для отключения триггеров
select 'disable trigger '+quotename(object_schema_name(tr.object_id))+'.'+quotename(tr.name)+' on '+quotename(schema_name(t.schema_id))+'.'+quotename(t.name)+';
GO
'
from sys.triggers tr
inner join sys.tables t
	on t.object_id = tr.parent_id
where tr.type = 'TR'
and tr.name like '%repl'

