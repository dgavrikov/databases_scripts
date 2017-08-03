-- Create DDL trigger for audit

create TABLE [dbo].[DatabaseLog](
	[DatabaseLogID] [int] IDENTITY(1,1) NOT NULL,
	[PostTime] [datetime] NOT NULL,
	[DatabaseUser] [sysname] NOT NULL,
	[LoginName] [sysname] NOT NULL,
	[Event] [sysname] NOT NULL,
	[Schema] [sysname] NULL,
	[Object] [sysname] NULL,
	[TSQL] [nvarchar](max) NOT NULL,
	[XmlEvent] [xml] NOT NULL,
 CONSTRAINT [PK_DatabaseLog_DatabaseLogID] PRIMARY KEY CLUSTERED 
(
	[DatabaseLogID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

create TRIGGER [ddlDatabaseTriggerLog] ON DATABASE 
FOR DDL_DATABASE_LEVEL_EVENTS AS 
BEGIN
SET NOCOUNT ON;
DECLARE @data XML;
DECLARE @schema sysname;
DECLARE @object sysname;
DECLARE @eventType sysname;
SET @data = EVENTDATA();
SET @eventType = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'sysname');
SET @schema = @data.value('(/EVENT_INSTANCE/SchemaName)[1]', 'sysname');
SET @object = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'sysname') 

INSERT [dbo].[DatabaseLog] 
(
[PostTime], 
[DatabaseUser], 
[LoginName],
[Event], 
[Schema], 
[Object], 
[TSQL], 
[XmlEvent]
) 
VALUES 
(
GETDATE(), 
CONVERT(sysname, CURRENT_USER),
@data.value('(/EVENT_INSTANCE/LoginName)[1]', 'sysname'), 
@eventType, 
CONVERT(sysname, @schema), 
CONVERT(sysname, @object), 
@data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(max)'), 
@data
);
END;

GO
