USE [SingleSSB];
GO

/*
Создание внутренней хранимой процедуры активации

Чтобы создать хранимую процедуру. Выполняемая хранимая процедура продолжает получать сообщения все 
время, пока таковые имеются в очереди. Если по истечении времени ожидания ни одного сообщения не 
получено, хранимая процедура завершается. Если полученное сообщение содержит запрос, хранимая процедура 
возвращает сообщение, содержащее ответ. Если полученное сообщение является сообщением EndDialog, хранимая 
процедура завершает целевую сторону диалога. Если полученное сообщение является сообщением Error, 
выполняется откат транзакции.
*/
    CREATE PROCEDURE TargetActivProc
    AS
      DECLARE @RecvReqDlgHandle UNIQUEIDENTIFIER;
      DECLARE @RecvReqMsg NVARCHAR(100);
      DECLARE @RecvReqMsgName sysname;

      WHILE (1=1)
      BEGIN

        BEGIN TRANSACTION;

        WAITFOR
        ( RECEIVE TOP(1)
            @RecvReqDlgHandle = conversation_handle,
            @RecvReqMsg = message_body,
            @RecvReqMsgName = message_type_name
          FROM [dbo].[TargetQueue]
        ), TIMEOUT 5000;

        IF (@@ROWCOUNT = 0)
        BEGIN
          ROLLBACK TRANSACTION;
          BREAK;
        END

        IF @RecvReqMsgName =
           N'[//SSBSExample/SingleDB/RequestMessage]'
        BEGIN
           DECLARE @ReplyMsg NVARCHAR(100);
           SELECT @ReplyMsg =
           N'<ReplyMsg>Message for Initiator service.</ReplyMsg>';
     
           SEND ON CONVERSATION @RecvReqDlgHandle
                  MESSAGE TYPE 
                  [//SSBSExample/SingleDB/ResponceMessage]
                  (@ReplyMsg);
        END
        ELSE IF @RecvReqMsgName =
            N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
        BEGIN
           END CONVERSATION @RecvReqDlgHandle;
        END
        ELSE IF @RecvReqMsgName =
            N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
        BEGIN
           END CONVERSATION @RecvReqDlgHandle;
        END
          
        COMMIT TRANSACTION;

      END
    GO
/*
Изменение целевой очереди для указания внутренней активации

Чтобы задать активацию компонентом Service Broker хранимой процедуры TargetActiveProc для 
обработки сообщений из очереди TargetQueueIntAct. Компонент Service Broker запускает копию 
процедуры TargetActiveProc каждый раз при получении сообщения в очереди TargetQueueIntAct 
при условии, что ни одна копия этой процедуры еще не запущена. Компонент Service Broker 
запускает дополнительные копии процедуры TargetActiveProc каждый раз, когда уже работающие 
копии не успевают обрабатывать входящие сообщения в имеющемся количестве.
*/
ALTER QUEUE dbo.TargetQueue
    WITH ACTIVATION
    ( STATUS = ON,
        PROCEDURE_NAME = TargetActivProc,
        MAX_QUEUE_READERS = 10,
        EXECUTE AS SELF
    );
GO

