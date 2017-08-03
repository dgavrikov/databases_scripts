/*
Создание ссылок на объекты инициатора

Измените предложение FROM FILE таким образом, чтобы оно указывало на папку, в которую скопирован 
файл InstInitiatorCertficate.cer в шаге 4 на занятии 2. Затем выполните этот код, чтобы создать 
учетную запись пользователя инициатора и поместить в нее целевой сертификат.
*/
USE InstTargetDB
GO
CREATE USER InitiatorUser WITHOUT LOGIN;

CREATE CERTIFICATE InstInitiatorCertificate
    AUTHORIZATION InitiatorUser
    FROM FILE = 
N'C:\SQL\InstInitiatorCertificate.cer';
GO

/*
Создание маршрутов

Вместо строки MyInitiatorComputer укажите имя компьютера, на котором выполняется 
экземпляр инициатора. Затем выполните код для создания маршрутов к целевой службе 
и службе инициатора, а также привязки удаленной службы, связывающей InitiatorUser 
с маршрутом службы инициатора.

В следующих инструкциях CREATE ROUTE предполагается, что в целевом экземпляре 
отсутствуют повторяющиеся имена служб. Если на целевом экземпляре в нескольких 
базах данных имеются службы с одинаковым именем, укажите в предложении BROKER_INSTANCE 
базу данных, для которой нужно открыть диалог.
*/
DECLARE @Cmd NVARCHAR(4000);

SET @Cmd = N'USE InstTargetDB;
CREATE ROUTE InstInitiatorRoute
WITH SERVICE_NAME =
        N''//InstDB/2InstSample/InitiatorService'',
        ADDRESS = N''TCP://SR-SQL-01:4022'';';

EXEC (@Cmd);

SET @Cmd = N'USE msdb
CREATE ROUTE InstTargetRoute
WITH SERVICE_NAME =
        N''//TgtDB/2InstSample/TargetService'',
        ADDRESS = N''LOCAL''';

EXEC (@Cmd);
GO
GRANT SEND
        ON SERVICE::[//TgtDB/2InstSample/TargetService]
        TO InitiatorUser;
GO
CREATE REMOTE SERVICE BINDING InitiatorBinding
        TO SERVICE N'//InstDB/2InstSample/InitiatorService'
        WITH USER = InitiatorUser;
GO
