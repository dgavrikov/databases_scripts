USE [master]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_get_object_by_definition] 
	@pattern nvarchar(max)
as
begin
	/*
		Author:	Dmitriy Gavrikov
		Note:	for hotkey in SSMS
	*/
	declare @sql varchar(4000) =
'select
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
	inner join sys.sql_modules M on O.object_id = M.object_id
where
	M.definition like N''%'+@pattern + '%''
order by
	O.name';
	exec(@sql);
end
