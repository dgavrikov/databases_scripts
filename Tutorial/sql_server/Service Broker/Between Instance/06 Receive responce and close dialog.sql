USE InstInitiatorDB;
GO

/*
Получение ответа и завершение диалога

Чтобы получить ответное сообщение и завершить диалог. Инструкция RECEIVE получает ответное 
сообщение из очереди InstInitiatorQueue. Инструкция END CONVERSATION завершает работу 
инициирующей стороны диалога. Последняя инструкция SELECT отображает текст ответного сообщения 
так, чтобы можно было подтвердить его идентичность сообщению, отправленному на предыдущем шаге.
*/
DECLARE @RecvReplyMsg NVARCHAR(100);
DECLARE @RecvReplyDlgHandle UNIQUEIDENTIFIER;

BEGIN TRANSACTION;

WAITFOR
( RECEIVE TOP(1)
    @RecvReplyDlgHandle = conversation_handle,
    @RecvReplyMsg = message_body
    FROM InstInitiatorQueue
), TIMEOUT 1000;

END CONVERSATION @RecvReplyDlgHandle;

-- Display recieved request.
SELECT @RecvReplyMsg AS ReceivedReplyMsg;

COMMIT TRANSACTION;
GO


/*
SELECT *
FROM [dbo].[InstTargetQueue]

SELECT *
FROM sys.transmission_queue
*/