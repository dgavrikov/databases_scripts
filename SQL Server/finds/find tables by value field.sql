declare @tbl table (cnt int not null,query nvarchar(4000)) 
declare @tbl_res table (cnt int not null,query nvarchar(4000)) 
declare @sql_text nvarchar(4000) ;
declare @param_def nvarchar(500)='@cnt int output';
declare @cnt int;
insert @tbl ( cnt, query )
select 0,'select @cnt = count(*) from '+quotename(object_schema_name(c.object_id))+'.'+quotename(object_name(c.object_id))+ ' with (nolock) where IdObject = 399610'
from sys.columns c
where name = 'IdObject'
and object_schema_name(c.object_id) not in ('sys','hist','tmp','Logs')

while exists (select 1 from @tbl where cnt = 0) begin
	select top 1 
		@sql_text = query
	from @tbl;
	exec sp_executesql @sql_text,@param_def ,@cnt = @cnt output;
	if @cnt > 0 
		insert into @tbl_res( cnt, query )values  (@cnt,@sql_text);
	delete @tbl where query = @sql_text;
	
end;

select * from @tbl_res;