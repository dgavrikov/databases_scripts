DECLARE @sql VARCHAR(1000)
WHILE EXISTS (
SELECT 1
FROM sys.conversation_endpoints
)
BEGIN

SELECT TOP 1 @sql = 'END CONVERSATION '''+CONVERT(VARCHAR(40),conversation_handle)+''' WITH CLEANUP'
FROM sys.conversation_endpoints

EXEC (@sql)
END
GO
