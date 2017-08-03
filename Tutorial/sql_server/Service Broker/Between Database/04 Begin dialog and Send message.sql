/*
Переключение в базу данных InitiatorDB

Чтобы переключить контекст в базу данных InitiatorDB, в которой инициируется диалог.
*/
USE InitiatorDB;
GO

/*
Начало диалога и отправка сообщения-запроса

Начать диалог и отправить сообщение-запрос к службе //TgtDB/2DBSample/TargetService в базе данных TargetDB. 
Этот код необходимо запускать единым блоком, поскольку для передачи дескриптора диалога из инструкции 
BEGIN DIALOG в инструкцию SEND используется переменная. Пакет запускает инструкцию BEGIN DIALOG, чтобы 
начать диалог и создать сообщение-запрос. Затем в инструкции SEND используется дескриптор диалога, чтобы 
отправить в этом диалоге сообщение-запрос. Последняя инструкция SELECT выводит текст отправленного сообщения.
*/
    DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
    DECLARE @RequestMsg NVARCHAR(100);

    BEGIN TRANSACTION;

    BEGIN DIALOG @InitDlgHandle
         FROM SERVICE [//InitDB/2DBSample/InitiatorService]
         TO SERVICE N'//TgtDB/2DBSample/TargetService'
         ON CONTRACT [//BothDB/2DBSample/SimpleContract]
         WITH
             ENCRYPTION = OFF;

    SELECT @RequestMsg =
       N'<RequestMsg>Message for Target service.</RequestMsg>';

    SEND ON CONVERSATION @InitDlgHandle
         MESSAGE TYPE [//BothDB/2DBSample/RequestMessage]
          (@RequestMsg);

    SELECT @RequestMsg AS SentRequestMsg;

    COMMIT TRANSACTION;
    GO
/*
Переключение в базу данных TargetDB

Переключить контекст в базу данных TargetDB, в которой будет получено сообщение-запрос 
и отправлено ответное сообщение в базу данных InitiatorDB.
*/
USE TargetDB;
GO

/*
Получение запроса и отправка ответа

Получить ответное сообщение из базы данных TargetQueue2DB и отправить ответное сообщение 
вызывающей стороне. Инструкция RECEIVE получает сообщение-запрос. Затем следующая инструкция 
SELECT выводит текст, позволяющий убедиться, что получено то же сообщение, что было отправлено 
на предыдущем шаге. Инструкция IF проверяет, имеет ли полученное сообщение тип запроса и 
используется ли инструкция SEND для отправки ответного сообщения инициатору. Она также проверяет, 
используется ли инструкция END CONVERSATION для завершения диалога на стороне цели. 
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
    FROM TargetQueue2DB
), TIMEOUT 1000;

SELECT @RecvReqMsg AS ReceivedRequestMsg;

IF @RecvReqMsgName =
    N'//BothDB/2DBSample/RequestMessage'
BEGIN
        DECLARE @ReplyMsg NVARCHAR(100);
        SELECT @ReplyMsg =
        N'<ReplyMsg>Message for Initiator service.</ReplyMsg>';
     
        SEND ON CONVERSATION @RecvReqDlgHandle
            MESSAGE TYPE
            [//BothDB/2DBSample/ReplyMessage] (@ReplyMsg);

        END CONVERSATION @RecvReqDlgHandle;
END

SELECT @ReplyMsg AS SentReplyMsg;

COMMIT TRANSACTION;
GO

/*
Переключение в базу данных InitiatorDB

Переключить контекст обратно в базу данных InitiatorDB, в которой будет получено ответное сообщение и завершится диалог.
*/
USE InitiatorDB;
GO

/*
Получение ответа и завершение диалога

Получить ответное сообщение и завершить диалог. Инструкция RECEIVE получает сообщение ответа из базы данных 
InitiatorQueue2DB. Инструкция END CONVERSATION завершает работу инициирующей стороны диалога. Последняя 
инструкция SELECT выводит текст ответного сообщения, что позволяет убедиться в том, что оно совпадает с 
сообщением, отправленным на предыдущем шаге.
*/
DECLARE @RecvReplyMsg NVARCHAR(100);
DECLARE @RecvReplyDlgHandle UNIQUEIDENTIFIER;

BEGIN TRANSACTION;

WAITFOR
( RECEIVE TOP(1)
    @RecvReplyDlgHandle = conversation_handle,
    @RecvReplyMsg = message_body
    FROM InitiatorQueue2DB
), TIMEOUT 1000;

END CONVERSATION @RecvReplyDlgHandle;

-- Display recieved request.
SELECT @RecvReplyMsg AS ReceivedReplyMsg;

COMMIT TRANSACTION;
GO

