declare @is_deadlock int = 0,  @Day datetime = convert(date, getdate()), @s varchar(100) = '', @err_num int, @err_mes nvarchar(100)

L_NEW_LAP:

begin try

select
	@is_deadlock = 0
	,@Day = '2010-09-01 00:00:00.000'
	,@s  = '';

while @Day > '2008'
begin

if not exists
(
	select *
	from sys.partition_range_values prv
	inner join sys.partition_functions pf
	on pf.function_id = prv.function_id
	where pf.name = 'DateRangePF'
		and value = @Day
)
begin
	set @s = convert(varchar(20), @Day, 112);
	raiserror('@Day = %s', 10, 1, @s) with NOWAIT;

	ALTER PARTITION SCHEME [DateRangePS]
	NEXT USED [PRIMARY];

	ALTER PARTITION FUNCTION [DateRangePF]()
	SPLIT RANGE (@Day);
end

SET @Day = DATEADD(DAY, -1, @Day);

end

end try
begin catch

select
	@err_num = ERROR_NUMBER()
	,@err_mes = ERROR_MESSAGE()

if @err_num = 1205
	and @err_mes like '%deadlock%'
	set @is_deadlock = 1

raiserror('error! %d %s',10,1,@err_num,@err_mes) with NOWAIT;

end catch

if @is_deadlock = 1
	GOTO L_NEW_LAP;