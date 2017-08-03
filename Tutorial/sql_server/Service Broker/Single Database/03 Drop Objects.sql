IF EXISTS (SELECT * FROM sys.services
           WHERE name =
           N'//SSBSExample/SingleDB/TargetService')
     DROP SERVICE
     [//SSBSExample/SingleDB/TargetService];

IF EXISTS (SELECT * FROM sys.service_queues
           WHERE name = N'TargetQueue')
     DROP QUEUE TargetQueue;

-- Drop the intitator queue and service if they already exist.
IF EXISTS (SELECT * FROM sys.services
           WHERE name =
           N'//SSBSExample/SingleDB/InitiatorService')
     DROP SERVICE
     [//SSBSExample/SingleDB/InitiatorService];

IF EXISTS (SELECT * FROM sys.service_queues
           WHERE name = N'InitiatorQueue')
     DROP QUEUE InitiatorQueue;

IF EXISTS (SELECT * FROM sys.service_contracts
           WHERE name =
           N'//SSBSExample/SingleDB/SingleContract')
     DROP CONTRACT
     [//SSBSExample/SingleDB/SingleContract];

IF EXISTS (SELECT * FROM sys.service_message_types
           WHERE name =
           N'//SSBSExample/SingleDB/RequestMessage')
     DROP MESSAGE TYPE
     [//SSBSExample/SingleDB/RequestMessage];

IF EXISTS (SELECT * FROM sys.service_message_types
           WHERE name =
           N'//SSBSExample/SingleDB/ResponceMessage')
     DROP MESSAGE TYPE
     [//SSBSExample/SingleDB/ResponceMessage];
GO