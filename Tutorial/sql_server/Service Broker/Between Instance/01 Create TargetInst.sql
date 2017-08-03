/*
Создание конечной точки компонента Service Broker

Cоздать конечную точку компонента Service Broker для данного экземпляра компонента Database Engine. 
Конечная точка компонента Service Broker определяет сетевой адрес, на который отправляются сообщения 
компонента Service Broker. Эта конечная точка по умолчанию компонента Service Broker использует 
TCP-порт 4022 и определяет, что удаленные экземпляры компонента Database Engine будут использовать 
для отправки сообщений соединения с проверкой подлинности Windows.

Проверка подлинности Windows работает, если оба компьютера находятся в одном домене или в доверенных доменах. 
Если компьютеры не расположены в доверенных доменах, используйте для защиты конечных точек сертификаты безопасности. 
Дополнительные сведения см. в разделе Как создать сертификаты для безопасности транспорта компонента Service Broker (Transact-SQL).
*/
USE master;
GO
IF EXISTS (SELECT * FROM master.sys.endpoints
            WHERE name = N'InstTargetEndpoint')
        DROP ENDPOINT InstTargetEndpoint;
GO
CREATE ENDPOINT InstTargetEndpoint
STATE = STARTED
AS TCP ( LISTENER_PORT = 4022 )
FOR SERVICE_BROKER (AUTHENTICATION = WINDOWS );
GO

/*
Создание целевой базы данных, главного ключа и пользователя

Измените пароль в инструкции CREATE MASTER KEY. Затем выполните код, чтобы создать целевую базу данных, 
которая будет использоваться для этого учебника. По умолчанию в новых базах данных включен параметр 
ENABLE_BROKER. Этот код также создает главный ключ и имя пользователя, которое будет применяться для 
поддержки шифрования и удаленных соединений.
*/
USE master;
GO
IF EXISTS (SELECT * FROM sys.databases
            WHERE name = N'InstTargetDB')
        DROP DATABASE InstTargetDB;
GO
CREATE DATABASE InstTargetDB;
GO

ALTER DATABASE InstTargetDB SET ENABLE_BROKER;
GO

USE InstTargetDB;
GO


CREATE MASTER KEY
        ENCRYPTION BY PASSWORD = N'q1w2e3R$T%Y^';
GO

CREATE USER TargetUser WITHOUT LOGIN;
GO
/*
Создание целевого сертификата

Измените имя файла, указанное в инструкции BACKUP CERTIFICATE, чтобы оно указывало 
на папку, расположенную на текущем компьютере. Затем выполните код, чтобы создать 
целевой сертификат, который будет использоваться для шифрования сообщений. В указанной 
папке должны быть заданы разрешения, предотвращающие доступ любых учетных записей,
кроме учетной записи Windows текущего пользователя и учетной записи Windows, с которой 
работает экземпляр компонента Database Engine. Для занятия 2 необходимо вручную скопировать 
файл InstTargetCertificate.cer в папку, доступ к которой будет осуществляться из 
инициирующего экземпляра.
*/
CREATE CERTIFICATE InstTargetCertificate 
        AUTHORIZATION TargetUser
        WITH SUBJECT = 'Target Certificate',
            EXPIRY_DATE = N'20161231';

BACKUP CERTIFICATE InstTargetCertificate
    TO FILE = 
N'C:\SQL\InstTargetCertificate.cer';
GO

/*
Создание типов сообщений

Выполните его, чтобы создать типы сообщений для диалога. Заданные здесь имена и 
свойства типов сообщений должны быть идентичны тем, которые будут созданы в базе 
данных InstInitiatorDB на следующем занятии.
*/
CREATE MESSAGE TYPE [//BothDB/2InstSample/RequestMessage]
        VALIDATION = WELL_FORMED_XML;
CREATE MESSAGE TYPE [//BothDB/2InstSample/ReplyMessage]
        VALIDATION = WELL_FORMED_XML;
GO

/*
Создание контракта

Чтобы создать контракт для диалога. Заданное здесь имя и свойства контракта 
должны быть такими же, как в контракте, который будет создан в базе данных 
InstInitiatorDB на следующем занятии.
*/
    CREATE CONTRACT [//BothDB/2InstSample/SimpleContract]
          ([//BothDB/2InstSample/RequestMessage]
             SENT BY INITIATOR,
           [//BothDB/2InstSample/ReplyMessage]
             SENT BY TARGET
          );
    GO
/*
Создание очереди и службы целевой стороны

Чтобы создать очередь и службу, которые будут использоваться для целевой стороны. 
Инструкция CREATE SERVICE связывает службу с очередью InstTargetQueue, чтобы все 
сообщения, отправленные службе, были получены очередью InstTargetQueue. Инструкция 
CREATE SERVICE также указывает, что использовать службу в качестве целевой могут 
только диалоги, использующие ранее созданный контракт //BothDB/2InstSample/SimpleContract.
*/
CREATE QUEUE InstTargetQueue;

CREATE SERVICE [//TgtDB/2InstSample/TargetService]
        AUTHORIZATION TargetUser
        ON QUEUE InstTargetQueue
        ([//BothDB/2InstSample/SimpleContract]);
GO

