
USE InstTargetDB;
GO

/*
Получение запроса и отправка ответа

Получение ответного сообщения из очереди InstTargetQueue и отправку ответного сообщения обратно инициатору. 
Инструкция RECEIVE получает сообщение-запрос. Затем следующая инструкция SELECT выводит текст, позволяющий 
убедиться, что получено то же сообщение, что было отправлено на предыдущем шаге. Инструкция IF проверяет, 
имеет ли полученное сообщение тип запроса и используется ли инструкция SEND для отправки ответного сообщения 
инициирующей стороне. Инструкция END CONVERSATION используется для завершения работы целевой стороны диалога. 
Последняя инструкция SELECT выводит текст ответного сообщения.
*/
DECLARE @RecvReqDlgHandle UNIQUEIDENTIFIER;
DECLARE @RecvReqMsg NVARCHAR(100);
DECLARE @RecvReqMsgName sysname;

BEGIN TRANSACTION;

WAITFOR
( RECEIVE TOP(1)
    @RecvReqDlgHandle = conversation_handle,
    @RecvReqMsg = message_body,
    @RecvReqMsgName = message_type_name
    FROM InstTargetQueue
), TIMEOUT 1000;

SELECT @RecvReqMsg AS ReceivedRequestMsg;

IF @RecvReqMsgName = N'//BothDB/2InstSample/RequestMessage'
BEGIN
        DECLARE @ReplyMsg NVARCHAR(100);
        SELECT @ReplyMsg =
        N'<ReplyMsg>Message for Initiator service.</ReplyMsg>';

        SEND ON CONVERSATION @RecvReqDlgHandle
            MESSAGE TYPE [//BothDB/2InstSample/ReplyMessage]
            (@ReplyMsg);

        END CONVERSATION @RecvReqDlgHandle;
END

SELECT @ReplyMsg AS SentReplyMsg;

COMMIT TRANSACTION;
GO

/*
SELECT *
FROM [dbo].[InstTargetQueue]

SELECT *
FROM sys.transmission_queue
*/