-- Поиск объекта в БД
DECLARE @FindText SYSNAME = '%Ankets%Notify%'

-- Поиск в объектах БД
SELECT 'Objects' AS Obj,OBJECT_SCHEMA_NAME(ao.object_id) AS SchemaName,ao.name AS ObjectName,ao.type_desc,sm.definition
FROM sys.all_objects ao 
LEFT JOIN sys.sql_modules sm
	ON sm.object_id = ao.object_id
WHERE ao.name LIKE @FindText
OR sm.definition LIKE @FindText

-- Поиск в зависимостях
SELECT 'Dependence' AS Obj,do.type_desc as DObjType,OBJECT_SCHEMA_NAME(do.object_id)+'.'+OBJECT_NAME(do.object_id) AS DependObject,ro.type_desc as RObjType,OBJECT_SCHEMA_NAME(ro.object_id)+'.'+OBJECT_NAME(ro.object_id) AS ReferenceObj
FROM sys.sql_dependencies sd
INNER JOIN sys.all_objects do
	ON sd.object_id = do.object_id
INNER JOIN sys.all_objects ro
	ON ro.object_id = sd.referenced_major_id
WHERE 
	OBJECT_NAME(sd.object_id) LIKE @FindText
OR	OBJECT_NAME(sd.referenced_major_id) LIKE @FindText

-- поиск в синонимах имя или ссылка на объект
SELECT 'Synonyms' AS Obj,OBJECT_SCHEMA_NAME(s.object_id) AS SchemaName,name as ObjectName,s.base_object_name
FROM sys.synonyms s
WHERE name LIKE @FindText
OR s.base_object_name LIKE @FindText

-- Поиск в линкед серверах
SELECT 'LinkedServers' AS Obj,	s.server_id,s.name,s.data_source
FROM sys.servers s 
WHERE name LIKE @FindText
OR s.data_source LIKE @FindText

-- ServiceBroker
SELECT 'SB_QUEUE' AS Obj,name
FROM sys.service_message_types smt
WHERE smt.name LIKE @FindText

SELECT 'SB_CONTRACT' AS Obj,name
FROM sys.service_contracts sc
WHERE sc.name LIKE @FindText

SELECT 'SB_SERVICE' AS Obj,OBJECT_SCHEMA_NAME(s.object_id) AS SchemaName,name as ObjectName,s.activation_procedure
FROM sys.service_queues  s 
WHERE s.name LIKE @FindText
OR s.activation_procedure LIKE @FindText

SELECT 'SB_SERVICE' AS Obj,name
FROM sys.services s 
WHERE s.name LIKE @FindText

SELECT 'SB_ROUTES' AS Obj,	r.name,
							r.remote_service_name,
							r.address
FROM sys.routes r 
WHERE 
	r.name LIKE @FindText
OR	r.remote_service_name LIKE @FindText
OR	r.address LIKE @FindText
