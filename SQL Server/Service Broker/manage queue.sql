-- список sysxmitqueue
SELECT p.[rows] as [XmitQ Depth]
FROM sys.objects as o JOIN sys.partitions AS p 
ON p.object_id = o.object_id
WHERE o.name = 'sysxmitqueue'

SELECT TOP 1 dateadd(hour, 3, enqueue_time) as enqueue_time
FROM [sys].[transmission_queue] WITH (NOLOCK)
ORDER BY enqueue_time ASC

-- статусы очередей
SELECT  state_desc,COUNT(*)
FROM sys.conversation_endpoints WITH (NOLOCK)
GROUP BY state_desc

-- скрипт по закрытию.
SELECT 'END CONVERSATION '''+CONVERT(VARCHAR(36),conversation_handle)+''' WITH CLEANUP
GO
',far_service,far_broker_instance
FROM sys.conversation_endpoints
WHERE state_desc = 'CLOSED'
far_service = 'http://alfa-direct.ru/SQL/_Queue/managers_InitiatorService_ADBACKSQL_ADBACKSQL'

-- скрипт по закрытию с проверкой сообщений.
SELECT distinct 'END CONVERSATION '''+CONVERT(VARCHAR(36),ce.conversation_handle)+''' WITH CLEANUP
GO
',far_service,far_broker_instance
FROM sys.conversation_endpoints ce
left join sys.transmission_queue tq
	on tq.conversation_handle = ce.conversation_handle
WHERE state_desc = 'CLOSED'
and tq.conversation_handle is null

-- чистка дополнительных таблиц
SELECT COUNT(*)
--DELETE sc
FROM orders.SessionConversations sc
LEFT JOIN sys.conversation_endpoints ce
	ON ce.conversation_handle = sc.Handle
WHERE ce.conversation_handle IS NULL
-- чистка дополнительных таблиц


SELECT DISTINCT far_service
FROM sys.conversation_endpoints
