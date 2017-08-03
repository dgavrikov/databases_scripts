select 'ALTER QUEUE '+QUOTENAME(SCHEMA_NAME(schema_id))+'.'+QUOTENAME(name)+' WITH STATUS = OFF
GO
',*
from sys.service_queues
where is_ms_shipped = 0