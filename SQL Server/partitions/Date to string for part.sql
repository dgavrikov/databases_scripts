/*
Собирает строку из дат для дотстановки в схемц секционирования.
Пример: '20160101','20160102','20160103',...
*/
DECLARE  @r datetime2 = '20140401 00:00:00.0000000'
DECLARE @str VARCHAR(MAX) =''

WHILE @r <= '20171231 00:00:00.0000000' BEGIN
	SELECT @str = @str +'N'''+CAST(@r AS varchar)+''','
	SET @r = DATEADD(DAY,1,@r)
END

SELECT @str