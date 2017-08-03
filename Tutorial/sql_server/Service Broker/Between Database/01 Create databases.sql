/*
Создание баз данных и установка параметра доверительных отношений

По умолчанию в новых базах данных включен параметр ENABLE_BROKER. Установка параметра TRUSTWORTHY 
в базе данных InitiatorDB позволяет начинать диалоги с целевыми службами в базе данных TargetDB.
*/

USE [master];
GO

IF EXISTS (SELECT * FROM sys.databases
           WHERE name = N'TargetDB')
     DROP DATABASE TargetDB;
GO
CREATE DATABASE TargetDB;
GO

ALTER DATABASE TargetDB SET ENABLE_BROKER
GO

IF EXISTS (SELECT * FROM sys.databases
           WHERE name = N'InitiatorDB')
     DROP DATABASE InitiatorDB;
GO
CREATE DATABASE InitiatorDB;
GO
ALTER DATABASE InitiatorDB SET ENABLE_BROKER
GO
ALTER DATABASE InitiatorDB SET TRUSTWORTHY ON;
GO