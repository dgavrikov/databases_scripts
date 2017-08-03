-- https://msdn.microsoft.com/ru-ru/library/bb839488%28v=sql.105%29.aspx
USE [master]
GO
/*
Создание базы данных
*/
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'SingleSSB')
	CREATE DATABASE [SingleSSB]
GO
/*
Включение SERVICE BROKER
*/
ALTER DATABASE [SingleSSB] SET ENABLE_BROKER
GO

USE [SingleSSB]
GO
/*
Создание типов сообщений

Поскольку на объекты Service Broker часто ссылаются несколько экземпляров компонента Database Engine, 
большинству объектов компонента Service Broker присваиваются имена в формате URI. Это помогает обеспечить 
уникальность имен в пределах нескольких компьютеров. Оба типа сообщений указывают, что компонент Service 
Broker проверяет лишь то, что сообщения являются правильными XML-документами, но не проверяет их 
корректность по конкретной схеме.
*/
CREATE MESSAGE TYPE
       [//SSBSExample/SingleDB/RequestMessage]
       VALIDATION = WELL_FORMED_XML;
CREATE MESSAGE TYPE
       [//SSBSExample/SingleDB/ResponceMessage]
       VALIDATION = WELL_FORMED_XML;
GO
/*
Создание контракта

Контракт указывает, что использующие его диалоги должны отправлять сообщения с типом 
[//SSBSExample/SingleDB/RequestMessage] от инициатора к цели, а сообщения с типом 
[//SSBSExample/SingleDB/ResponceMessage] — от цели к инициатору.
*/
CREATE CONTRACT [//SSBSExample/SingleDB/SingleContract]
      ([//SSBSExample/SingleDB/RequestMessage]
       SENT BY INITIATOR,
       [//SSBSExample/SingleDB/ResponceMessage]
       SENT BY TARGET
      );
GO
/*
Создание очереди и службы целевой (target - цель) стороны

Поскольку ссылки на очереди из одной и той же базы данных напоминают ссылки на 
таблицы и представления, очереди имеют такие же имена, что и таблицы и представления. 
Инструкция CREATE SERVICE связывает службу с очередью TargetQueue. Поэтому все сообщения, 
отправленные службе, будут помещены в очередь TargetQueue. Инструкция CREATE SERVICE 
также указывает, что только диалоги, использующие созданный ранее контракт 
[//SSBSExample/SingleDB/SingleContract], могут пользоваться этой службой в качестве целевой.
*/
CREATE QUEUE TargetQueue;

CREATE SERVICE
       [//SSBSExample/SingleDB/TargetService]
       ON QUEUE TargetQueue
       ([//SSBSExample/SingleDB/SingleContract]);
GO
/*
Создание очереди и службы инициирующей стороны

Поскольку не указано имя контракта, никакие другие службы не могут использовать эту службу в качестве целевой.
*/

CREATE QUEUE InitiatorQueue;

CREATE SERVICE
       [//SSBSExample/SingleDB/InitiatorService]
       ON QUEUE InitiatorQueue;
GO

