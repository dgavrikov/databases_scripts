USE InitiatorDB;
GO
/*
Создание типов сообщений

Указанные здесь имена и свойства типов сообщений должны быть идентичны тем, 
которые были созданы в базе данных TargetDB на предыдущем занятии.
*/
CREATE MESSAGE TYPE [//BothDB/2DBSample/RequestMessage]
        VALIDATION = WELL_FORMED_XML;
CREATE MESSAGE TYPE [//BothDB/2DBSample/ReplyMessage]
        VALIDATION = WELL_FORMED_XML;
GO
/*
Создание контракта

Указанное здесь имя и свойства контракта должны быть идентичны имени и 
свойствам контракта, который был создан в базе данных TargetDB на 
предыдущем занятии.
*/
CREATE CONTRACT [//BothDB/2DBSample/SimpleContract]
        ([//BothDB/2DBSample/RequestMessage]
            SENT BY INITIATOR,
        [//BothDB/2DBSample/ReplyMessage]
            SENT BY TARGET
        );
GO
/*
Создание очереди и службы инициирующей стороны

Затем запустите его, чтобы создать очередь и службу, которые будут использоваться 
для инициирующей стороны. Поскольку не указано имя контракта, никакие другие 
службы не могут использовать эту службу в качестве целевой.
*/
CREATE QUEUE InitiatorQueue2DB;

CREATE SERVICE [//InitDB/2DBSample/InitiatorService]
        ON QUEUE InitiatorQueue2DB;
GO

