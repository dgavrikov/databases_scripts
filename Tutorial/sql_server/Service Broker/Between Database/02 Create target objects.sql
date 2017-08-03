USE TargetDB;
GO
/*
Создание типов сообщений

Указанные имена и свойства типов сообщений должны быть идентичны тем, которые будут 
созданы в базе данных InitiatorDB на следующем занятии.
*/
    CREATE MESSAGE TYPE [//BothDB/2DBSample/RequestMessage]
           VALIDATION = WELL_FORMED_XML;
    CREATE MESSAGE TYPE [//BothDB/2DBSample/ReplyMessage]
           VALIDATION = WELL_FORMED_XML;
    GO
/*
Создание контракта

Заданное имя и свойства контракта должны быть идентичны имени и свойствам 
контракта, который будет создан в базе данных InitiatorDB на следующем занятии.
*/
    CREATE CONTRACT [//BothDB/2DBSample/SimpleContract]
          ([//BothDB/2DBSample/RequestMessage]
             SENT BY INITIATOR,
           [//BothDB/2DBSample/ReplyMessage]
             SENT BY TARGET
          );
    GO
/*
Создание очереди и службы целевой стороны

Затем запустите его, чтобы создать очередь и службу, которые будут использоваться 
для целевой стороны. Инструкция CREATE SERVICE связывает службу с очередью 
TargetQueue2DB. Таким образом, все отправляемые службе сообщения помещаются в очередь 
TargetQueue2DB. Инструкция CREATE SERVICE также указывает, что только диалоги, 
использующие созданный ранее контракт //BothDB/2DBSample/SimpleContract, 
могут пользоваться этой службой в качестве целевой.
*/
    CREATE QUEUE TargetQueue2DB;

    CREATE SERVICE [//TgtDB/2DBSample/TargetService]
           ON QUEUE TargetQueue2DB
           ([//BothDB/2DBSample/SimpleContract]);
    GO

