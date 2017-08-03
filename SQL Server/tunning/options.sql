-- функции для просмотра опций подключения
Use [master]
Go

create function dbo.GetOptions(@option int)
returns table as return (
select 
	case when (@option &	0x1) > 0 then 1 else 0 end as [DISABLE_DEF_CNST_CHK],
	case when (@option &	0x2) > 0 then 1 else 0 end as [IMPLICIT_TRANSACTIONS],
	case when (@option &	0x4) > 0 then 1 else 0 end as [CURSOR_CLOSE_ON_COMMIT],
	case when (@option &	0x8) > 0 then 1 else 0 end as [ANSI_WARNINGS],
	case when (@option &	0x10) > 0 then 1 else 0 end as [ANSI_PADDING],
	case when (@option &	0x20) > 0 then 1 else 0 end as [ANSI_NULLS],
	case when (@option &	0x40) > 0 then 1 else 0 end as [ARITHABORT],
	case when (@option &	0x80) > 0 then 1 else 0 end as [ARITHIGNORE],
	case when (@option &	0x100) > 0 then 1 else 0 end as [QUOTED_IDENTIFIER],
	case when (@option &	0x200) > 0 then 1 else 0 end as [NOCOUNT],
	case when (@option &	0x400) > 0 then 1 else 0 end as [ANSI_NULL_DFLT_ON],
	case when (@option &	0x800) > 0 then 1 else 0 end as [ANSI_NULL_DFLT_OFF],
	case when (@option &	0x1000) > 0 then 1 else 0 end as [CONCAT_NULL_YIELDS_NULL],
	case when (@option &	0x2000) > 0 then 1 else 0 end as [NUMERIC_ROUNDABORT],
	case when (@option &	0x4000) > 0 then 1 else 0 end as [XACT_ABORT]
)
go
create function dbo.GetOptionsList(@option int)
returns table as return (
select N'DISABLE_DEF_CNST_CHK' as [OPTION], case when (@option &	0x1) > 0 then 1 else 0 end as [VALUE]
union all
select N'IMPLICIT_TRANSACTIONS' as [OPTION], case when (@option &	0x2) > 0 then 1 else 0 end as [VALUE]
union all
select N'CURSOR_CLOSE_ON_COMMIT' as [OPTION], case when (@option & 0x4) > 0 then 1 else 0 end as [VALUE]
union all
select N'ANSI_WARNINGS' as [OPTION], case when (@option &	0x8) > 0 then 1 else 0 end as [VALUE]
union all
select N'ANSI_PADDING' as [OPTION], case when (@option &	0x10) > 0 then 1 else 0 end as [VALUE]
union all
select N'ANSI_NULLS' as [OPTION], case when (@option & 0x20) > 0 then 1 else 0 end as [VALUE]
union all
select N'ARITHABORT' as [OPTION], case when (@option & 0x40) > 0 then 1 else 0 end as [VALUE]
union all
select N'ARITHIGNORE' as [OPTION], case when (@option & 0x80) > 0 then 1 else 0 end as [VALUE]
union all
select N'QUOTED_IDENTIFIER' as [OPTION], case when (@option & 0x100) > 0 then 1 else 0 end as [VALUE]
union all
select N'NOCOUNT' as [OPTION], case when (@option &	 0x200) > 0 then 1 else 0 end as [VALUE]
union all
select N'ANSI_NULL_DFLT_ON' as [OPTION], case when (@option & 0x400) > 0 then 1 else 0 end as [VALUE]
union all
select N'ANSI_NULL_DFLT_OFF' as [OPTION], case when (@option & 0x800) > 0 then 1 else 0 end as [VALUE]
union all
select N'CONCAT_NULL_YIELDS_NULL' as [OPTION], case when (@option & 0x1000) > 0 then 1 else 0 end as [VALUE]
union all
select N'NUMERIC_ROUNDABORT' as [OPTION], case when (@option &	0x2000) > 0 then 1 else 0 end as [VALUE]
union all
select N'XACT_ABORT' as [OPTION], case when (@option & 0x4000) > 0 then 1 else 0 end as [VALUE]
)
go

select * from master..GetOptions(@@OPTIONS)
go
select * from master..GetOptionsList(@@OPTIONS)
go
