/*
Создание конечной точки компонента Service Broker

Чтобы создать конечную точку компонента Service Broker для данного экземпляра компонента 
Database Engine. Конечная точка Service Broker указывает сетевой адрес, по которому 
направляются сообщения Service Broker. Эта конечная точка использует установленный по 
умолчанию компонентом Service Broker порт TCP/IP 4022 и указывает на то, что удаленные 
экземпляры Database Engine при отправке сообщений будут использовать средства проверки 
подлинности Windows.

Система проверки подлинности Windows функционирует, когда оба компьютера находятся в одном 
и том же домене либо в доверенных доменах. Если компьютеры не расположены в доверенных 
доменах, используйте для защиты конечных точек сертификаты безопасности. Дополнительные 
сведения см. в разделе Как создать сертификаты для безопасности транспорта компонента 
Service Broker (Transact-SQL).
*/
USE master;
GO
IF EXISTS (SELECT * FROM sys.endpoints
            WHERE name = N'InstInitiatorEndpoint')
        DROP ENDPOINT InstInitiatorEndpoint;
GO
CREATE ENDPOINT InstInitiatorEndpoint
STATE = STARTED
AS TCP ( LISTENER_PORT = 4022 )
FOR SERVICE_BROKER (AUTHENTICATION = WINDOWS );
GO

/**
Создание инициирующей базы данных, главного ключа и пользователя

Измените пароль в инструкции CREATE MASTER KEY. Затем запустите код для создания 
целевой базы данных, которая используется в этом учебнике. По умолчанию в новых 
базах данных включен параметр ENABLE_BROKER. Этот код также создает главный ключ 
и пользователя, который будет применяться для поддержки шифрования и удаленных соединений.
*/
USE master;
GO
IF EXISTS (SELECT * FROM sys.databases
            WHERE name = N'InstInitiatorDB')
        DROP DATABASE InstInitiatorDB;
GO
CREATE DATABASE InstInitiatorDB;
GO
ALTER DATABASE InstInitiatorDB SET ENABLE_BROKER
GO

USE InstInitiatorDB;
GO

CREATE MASTER KEY
        ENCRYPTION BY PASSWORD = N'q1w2e3R$T%Y^';
GO
CREATE USER InitiatorUser WITHOUT LOGIN;
GO

/*
Создание сертификата инициатора

Измените имя файла, указанное в инструкции BACKUP CERTIFICATE, чтобы оно указывало на папку, 
расположенную на текущем компьютере. Затем запустите этот код для создания сертификата 
инициатора, используемого для шифрования сообщений. В указанной папке должны быть заданы 
разрешения, предотвращающие доступ любых учетных записей, кроме учетной записи Windows текущего 
пользователя и учетной записи Windows, с которой работает экземпляр компонента Database Engine. 
Для занятия 3 вы должны вручную скопировать файл InstInitiatorCertificate.cer в папку, доступную 
из целевого экземпляра.
*/
CREATE CERTIFICATE InstInitiatorCertificate
        AUTHORIZATION InitiatorUser
        WITH SUBJECT = N'Initiator Certificate',
            EXPIRY_DATE = N'20151231';

BACKUP CERTIFICATE InstInitiatorCertificate
    TO FILE = 
N'C:\SQL\InstInitiatorCertificate.cer';
GO

/*
Создание типов сообщений

Чтобы создать типы сообщений для диалога. Имена типов сообщений и указанные здесь свойства должны 
быть идентичными именам и свойствам, которые были созданы в базе данных InstTargetDB на предыдущем 
занятии.
*/
CREATE MESSAGE TYPE [//BothDB/2InstSample/RequestMessage]
        VALIDATION = WELL_FORMED_XML;
CREATE MESSAGE TYPE [//BothDB/2InstSample/ReplyMessage]
        VALIDATION = WELL_FORMED_XML;
GO

/*
Создание контракта

Чтобы создать контракт для диалога. Имя контракта и свойства, указанные здесь, должны быть идентичными 
контракту, который вы будете создавать в базе данных InstInitiatorDB на следующем занятии.
*/
CREATE CONTRACT [//BothDB/2InstSample/SimpleContract]
        ([//BothDB/2InstSample/RequestMessage]
            SENT BY INITIATOR,
        [//BothDB/2InstSample/ReplyMessage]
            SENT BY TARGET
        );
GO
/*
Создание очереди и службы инициатора

Чтобы создать очередь и службу, которые будут использоваться для целевой стороны. Инструкция CREATE 
SERVICE ассоциирует эту службу с очередью InstInitiatorQueue. Следовательно, все направляемые службе 
сообщения будут получены очередью InstInitiatorQueue. Инструкция CREATE SERVICE также указывает, что 
использовать службу в качестве целевой могут только диалоги, использующие ранее созданный контракт 
//BothDB/2InstSample/SimpleContract.
*/
CREATE QUEUE InstInitiatorQueue;

CREATE SERVICE [//InstDB/2InstSample/InitiatorService]
        AUTHORIZATION InitiatorUser
        ON QUEUE InstInitiatorQueue;
GO

/*
Создание ссылок на целевые объекты

Измените предложение FROM FILE, поместив в него ссылку на папку, в которую вы скопировали файл 
InstTargetCertficate.cer из шага 3 занятия 1. Затем запустите код для создания целевого пользователя 
и запросите целевой сертификат.
*/
CREATE USER TargetUser WITHOUT LOGIN;

CREATE CERTIFICATE InstTargetCertificate 
    AUTHORIZATION TargetUser
    FROM FILE = 
N'C:\SQL\InstTargetCertificate.cer'
GO

/*
Создание маршрутов

Вместо строки MyTargetComputer введите имя компьютера, на котором выполняется целевой экземпляр. 
Затем запустите код для создания маршрутов к целевой службе и к инициирующей службе, а также 
привязку удаленной службы, которая ассоциирует пользователя TargetUser с маршрутом к целевой службе.

В следующих инструкциях CREATE ROUTE предполагается, что в целевом экземпляре отсутствуют повторяющиеся 
имена служб. Если несколько баз данных на целевом экземпляре имеют службы с идентичными именами, 
используйте предложение BROKER_INSTANCE для указания базы данных, из которой необходимо открыть диалог.
*/
DECLARE @Cmd NVARCHAR(4000);

SET @Cmd = N'USE InstInitiatorDB;
CREATE ROUTE InstTargetRoute
WITH SERVICE_NAME =
        N''//TgtDB/2InstSample/TargetService'',
        ADDRESS = N''TCP://SR-SQL-02:4022'';';

EXEC (@Cmd);

SET @Cmd = N'USE msdb
CREATE ROUTE InstInitiatorRoute
WITH SERVICE_NAME =
        N''//InstDB/2InstSample/InitiatorService'',
        ADDRESS = N''LOCAL''';

EXEC (@Cmd);
GO
CREATE REMOTE SERVICE BINDING TargetBinding
        TO SERVICE
            N'//TgtDB/2InstSample/TargetService'
        WITH USER = TargetUser;

GO

