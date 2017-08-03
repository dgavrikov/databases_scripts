--—крипт для вытаскивания всех таблиц и их полей с описаниями
;with allDescr as (
	select col.name [objName], isnull(ep.value, '') [MS_Description], col.column_id, col.object_id
				, typ.name				
				, case 
						when col.max_length = -1 
							then 'max' 
						when typ.name = 'nvarchar' 
							then cast(col.max_length/2 as nvarchar)
						else '' end max_length
				, case when col.is_nullable = 0 then 'not null' else 'null' end is_nullable
				, cast(col.max_length as nvarchar) bytes
				
		from
				sys.schemas sch
			inner join
				sys.tables tab
					on 
							tab.schema_id = sch.schema_id
						and sch.name not in ('dbo', 'sys')			
			inner join
				sys.columns col 
					on col.object_id = tab.object_id
			inner join
				sys.types typ
					on
							typ.system_type_id = col.system_type_id
						and typ.user_type_id = col.user_type_id
			left outer join
				sys.extended_properties ep 
					on ep.major_id = tab.object_id and ep.minor_id = col.column_id
	union all
	select '[' + sch.name + '].[' + tab.name + ']', isnull(ep.value, ''), 0, tab.object_id, '', '', '', ''
		from
				sys.schemas sch
			inner join
				sys.tables tab
					on 
							tab.schema_id = sch.schema_id
						and sch.name not in ('dbo', 'sys')						
			left outer join
				sys.extended_properties ep 
					on ep.major_id = tab.object_id and ep.minor_id = 0)
select [objName],[MS_Description], name,  max_length, is_nullable, bytes from allDescr
	order by object_id, column_id