SELECT far_service,far_broker_instance,COUNT(*)
FROM sys.conversation_endpoints
GROUP BY far_service ,
         far_broker_instance
ORDER BY far_service

select p.[rows] as [XmitQ Depth]
FROM sys.objects as o JOIN sys.partitions AS p 
ON p.object_id = o.object_id
WHERE o.name = 'sysxmitqueue'

SELECT TOP 1 dateadd(hour, 3, enqueue_time) as enqueue_time2,conversation_handle ,
                                                             to_service_name ,
                                                             to_broker_instance ,
                                                             from_service_name ,
                                                             service_contract_name ,
                                                             enqueue_time ,
                                                             message_sequence_number ,
                                                             message_type_name ,
                                                             is_conversation_error ,
                                                             is_end_of_dialog ,
                                                             message_body ,
                                                             transmission_status ,
                                                             priority
FROM [sys].[transmission_queue] WITH (NOLOCK)
ORDER BY enqueue_time2 asc


-- спирт по закрытию.
SELECT 'END CONVERSATION '''+CONVERT(VARCHAR(36),conversation_handle)+''' WITH CLEANUP
GO
'
FROM sys.conversation_endpoints
WHERE --state_desc = 'DISCONNECTED_OUTBOUND'
far_service = 'http://alfa-direct.ru/SQL/_Queue/accounts_TargetService_POSTTRADEFOND'

-- чистка дополнительных таблиц
SELECT COUNT(*)
--DELETE sc
FROM accounts.SessionConversations sc
LEFT JOIN sys.conversation_endpoints ce
	ON ce.conversation_handle = sc.Handle
WHERE ce.conversation_handle IS NULL
-- чистка дополнительных таблиц
