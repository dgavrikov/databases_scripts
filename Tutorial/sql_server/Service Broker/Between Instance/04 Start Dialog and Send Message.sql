USE InstInitiatorDB;
GO
/*
Начало диалога и отправка сообщения-запроса

Чтобы начать диалог, и направьте сообщение-запрос целевой службе 
//TgtDB/2InstSample/TargetService в базе данных InstTargetDB. Этот код необходимо запускать 
единым блоком, поскольку для передачи дескриптора диалога из инструкции BEGIN DIALOG в 
инструкцию SEND используется переменная. Пакет выполняет инструкцию BEGIN DIALOG для начала 
диалога, а затем создает сообщение-запрос. Затем в инструкции SEND используется дескриптор 
диалога для отправки в этом диалоге сообщения-запроса. Последняя инструкция SELECT просто 
отображает текст отправленного сообщения.
*/
DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
DECLARE @RequestMsg NVARCHAR(100);

BEGIN TRANSACTION;

BEGIN DIALOG @InitDlgHandle
        FROM SERVICE [//InstDB/2InstSample/InitiatorService]
        TO SERVICE N'//TgtDB/2InstSample/TargetService'
        ON CONTRACT [//BothDB/2InstSample/SimpleContract]
        WITH
            ENCRYPTION = ON;

SELECT @RequestMsg = N'<RequestMsg>Message for Target service.</RequestMsg>';

SEND ON CONVERSATION @InitDlgHandle
        MESSAGE TYPE [//BothDB/2InstSample/RequestMessage]
        (@RequestMsg);

SELECT @RequestMsg AS SentRequestMsg;

COMMIT TRANSACTION;
GO
/*
SELECT *
FROM [dbo].[InstInitiatorQueue]

SELECT *
FROM sys.transmission_queue
*/