USE [master]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_get_object_info_by_name] 
	@object_name sysname
as
begin
	/*
		Author:	Dmitriy Gavrikov
		Note:	for hotkey in SSMS
	*/
	declare @sql varchar(2000);

	set @sql = '
select
	 O.name					as [object_name]
	,quotename(schema_name(O.schema_id))+''.''+quotename(O.name) 
							as [full_name]
	,O.object_id
	,O.parent_object_id
	,O.type
	,O.type_desc
	,O.create_date
	,O.modify_date
	,O.is_ms_shipped
	,M.definition
from
	sys.all_objects O
	left join sys.sql_modules M on O.object_id = M.object_id
where
	name like N'''+@object_name + '%''
order by
	O.name';
	exec (@sql);
end
