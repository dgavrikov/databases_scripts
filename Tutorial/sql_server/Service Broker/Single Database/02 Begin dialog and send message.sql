USE [SingleSSB]
GO
/*
Начните диалог и отправьте сообщение-запрос

Этот код необходимо запускать единым блоком, поскольку для передачи дескриптора диалога из инструкции 
BEGIN DIALOG в инструкцию SEND используется переменная. Пакет выполняет инструкцию BEGIN DIALOG для 
начала диалога. Он формирует сообщение-запрос и затем с помощью дескриптора диалога в инструкции SEND 
направляет сообщение-запрос по этому диалогу. Последняя инструкция SELECT выводит текст отправленного сообщения.
*/

DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
DECLARE @RequestMsg NVARCHAR(100);

BEGIN TRANSACTION;

BEGIN DIALOG @InitDlgHandle
     FROM SERVICE
      [//SSBSExample/SingleDB/InitiatorService]
     TO SERVICE
      N'//SSBSExample/SingleDB/TargetService'
     ON CONTRACT
      [//SSBSExample/SingleDB/SingleContract]
     WITH
         ENCRYPTION = OFF;

SELECT @RequestMsg =
       N'<RequestMsg>Message for Target service.</RequestMsg>';

SEND ON CONVERSATION @InitDlgHandle
     MESSAGE TYPE 
     [//SSBSExample/SingleDB/RequestMessage]
     (@RequestMsg);

SELECT @RequestMsg AS SentRequestMsg;

COMMIT TRANSACTION;
GO

/*
Получение запроса и отправка ответа

Затем запустите его для получения ответного сообщения от базы данных TargetQueue1DB и направьте 
сообщение-ответ обратно инициатору. Инструкция RECEIVE получает сообщение-запрос. Следующая 
инструкция SELECT отображает текст, чтобы можно было проверить, является ли он сообщением, 
отправленным на последнем шаге. Инструкция IF проверяет, имеет ли полученное сообщение тип запроса
и используется ли инструкция SEND для отправки ответного сообщения инициатору. 
Инструкция END CONVERSATION используется для завершения работы целевой стороны диалога. 
Последняя инструкция SELECT выводит текст ответного сообщения.
*/

SELECT *
FROM [dbo].[InitiatorQueue]

SELECT *
FROM [dbo].[TargetQueue]

DECLARE @RecvReqDlgHandle UNIQUEIDENTIFIER;
DECLARE @RecvReqMsg NVARCHAR(100);
DECLARE @RecvReqMsgName sysname;

BEGIN TRANSACTION;

WAITFOR
( RECEIVE TOP(1)
    @RecvReqDlgHandle = conversation_handle,
    @RecvReqMsg = message_body,
    @RecvReqMsgName = message_type_name
  FROM TargetQueue
), TIMEOUT 1000;

SELECT @RecvReqMsg AS ReceivedRequestMsg;

IF @RecvReqMsgName =
   N'//SSBSExample/SingleDB/RequestMessage'
BEGIN
     DECLARE @ReplyMsg NVARCHAR(100);
     SELECT @ReplyMsg =
     N'<ReplyMsg>Im read message/ all right</ReplyMsg>';
 
     SEND ON CONVERSATION @RecvReqDlgHandle
          MESSAGE TYPE 
          [//SSBSExample/SingleDB/ResponceMessage]
          (@ReplyMsg);

     END CONVERSATION @RecvReqDlgHandle;
END

SELECT @ReplyMsg AS SentReplyMsg;

COMMIT TRANSACTION;
GO

/*
Получение ответа и завершение диалога

Инструкция RECEIVE получает ответное сообщение из базы данных IInitiatorQueue1DB. 
Инструкция END CONVERSATION завершает работу инициирующей стороны диалога. Последняя 
инструкция SELECT выводит текст ответного сообщения, что позволяет убедиться в том, 
что оно совпадает с сообщением, отправленным на предыдущем шаге.
*/

DECLARE @RecvReplyMsg NVARCHAR(100);
DECLARE @RecvReplyDlgHandle UNIQUEIDENTIFIER;

BEGIN TRANSACTION;

WAITFOR
( RECEIVE TOP(1)
    @RecvReplyDlgHandle = conversation_handle,
    @RecvReplyMsg = message_body
  FROM InitiatorQueue
), TIMEOUT 1000;

END CONVERSATION @RecvReplyDlgHandle;

SELECT @RecvReplyMsg AS ReceivedReplyMsg;

COMMIT TRANSACTION;
GO