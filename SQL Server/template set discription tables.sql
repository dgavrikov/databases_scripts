with tablesInfo as (
	select sch.name [sch], tab.name [tab], col.name [col], isnull(cast(ep.value as nvarchar), '') [description], tab.object_id [tab_object_id]
		from 
				sys.schemas sch
			inner join
				sys.tables tab
					on 
							tab.schema_id = sch.schema_id
						and sch.name not in ('sys')
			inner join
				sys.columns col
					on col.object_id = tab.object_id
			left outer join
				sys.extended_properties ep 
					on ep.major_id = tab.object_id and ep.minor_id = col.column_id
	)
,tabNames as (
	select distinct ti.sch, ti.tab, isnull(cast(ep.value as nvarchar), '') [description]
		from 
				tablesInfo ti
			left outer join
				sys.extended_properties ep 
					on ep.major_id = ti.[tab_object_id] and ep.minor_id = 0
	)
select tabNames.sch, tabNames.tab,
'execute [sysAdd].[AddColumnDescription]
			'''+tabNames.sch+''', '''+tabNames.tab+''', '''+tabNames.[description]+''' '+(select [sysAdd].[Concatenate]('
			, '''+ti.col+''', '''+ti.[description]+'''')
						from
							tablesInfo ti
						where ti.tab = tabNames.tab and ti.col != 'versionId')+'' [AddComment]
	from
		tabNames tabNames
	order by
		tabNames.sch, tabNames.tab