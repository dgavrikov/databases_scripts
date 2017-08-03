-- Создаем схему для DBA
--------------------------
if schema_id('dbatools') is null
exec sp_sqlexec 'create schema dbatools'
go

-- Табличка с системными параметрами
----------------------------------------
if OBJECT_ID(N'dbatools.sys_params',N'U') is not null
	drop table dbatools.sys_params;
go
CREATE TABLE dbatools.sys_params(
		[param] [varchar](512) NOT NULL,
		[value_char] [varchar](128),
		[value_int] int,
Constraint PK_sys_params Primary key (param)
	) 
GO
-- создаем последовательность
IF object_id ('dbatools.service_index',N'SO') is not null
	drop sequence dbatools.service_index 
create sequence dbatools.service_index as bigint start with 1;

-- таблица для отчетов по обслуживанию
---------------------------------------
if OBJECT_ID(N'dbatools.rep_errors',N'U') is not null
	drop table dbatools.rep_errors
go
if OBJECT_ID(N'dbatools.rep_service_index',N'U') is not null
	drop table dbatools.rep_service_index
go
create table dbatools.rep_service_index(
record_id bigint not null identity(1,1) unique,
table_name nvarchar(257)not null,
idx_name nvarchar(128) not null,
start_time datetime not null,
end_time datetime,
oper_type smallint,
oper_type_desc as case oper_type
when 10 then 'smart defrag'
when 11 then 'smart rebuild'
else 'unknow'
end,
oper_num bigint not null default 0,
fragmentation_in_percent decimal(5,2) not null default 0.00,
page_count bigint not null default 0,
part_numb int not null  default 0,
[description] nvarchar(300) null
)
go
CREATE INDEX [ix_service_index_1] ON [dbatools].[rep_service_index] 
(
	[oper_num] ASC
	
) include ([start_time],[end_time])
GO
create index [ix_service_index_2] on [dbatools].[rep_service_index] 
(
[oper_type] ASC
)include ([oper_num])
GO	

create index [ix_service_index_3] on [dbatools].[rep_service_index](start_time desc)
include(table_name,idx_name,part_numb,fragmentation_in_percent,page_count)
go

-- errors (report)
create table dbatools.rep_errors(
record_id bigint not null,
error_message nvarchar(max)
)
go
alter table dbatools.rep_errors add constraint FK_Err_RecId foreign key(record_id)  references dbatools.rep_service_index(record_id) on delete cascade
go
grant select on dbatools.rep_errors to public
go

-- Exclude index
if OBJECT_ID(N'dbatools.rep_service_index_exclude',N'U') is not null
	drop table dbatools.rep_service_index_exclude
go
create table dbatools.rep_service_index_exclude(
obj_id int not null,
idx_id int not null,
comment varchar(128),
Primary key (obj_id,idx_id)
)
go
grant select on dbatools.rep_service_index to public
go
insert into dbatools.rep_service_index_exclude(obj_id,idx_id,comment)
select i.OBJECT_ID,i.index_id,
	 quotename(object_schema_name(i.object_id,db_id()))+'.'+quotename(object_name(i.object_id)) as comment 
from sys.indexes as i
where	  object_schema_name(i.object_id,db_id()) = 'dbatools'
and	  object_name(i.object_id)  in ('rep_service_index','rep_service_index_exclude','rep_errors')
go
if object_id(N'dbatools.v_indexes',N'V') is not null
	drop view dbatools.v_indexes;
go

-- Расширенное представление по индексам
-----------------------------------------
create view [dbatools].[v_indexes] 
as
select 	
		SCHEMA_ID(OBJECT_SCHEMA_NAME(ix.object_id,DB_ID())) as [schema_id],		
		OBJECT_SCHEMA_NAME(ix.object_id,DB_ID()) as [schema_name],
		ix.object_id as [object_id],
		OBJECT_NAME(ix.object_id) as [object_name],
		ix.index_id as [index_id],
		ix.Name as [index_name],
		ix.type,
		ix.type_desc,
		ix.is_unique,
		ix.data_space_id,
		case ds.type
			when 'FG' then ds.name
			when 'PS' then (select distinct name from sys.partition_schemes where data_space_id = ix.data_space_id)
		end as data_space,
		isnull((select fanout from sys.partition_functions prtfn
									join sys.partition_schemes as prtsch on prtfn.function_id = prtsch.function_id
									where prtsch.data_space_id =  ix.data_space_id),0) as part_count,
		ix.ignore_dup_key,
		ix.is_primary_key,
		ix.is_unique_constraint,
		ix.fill_factor,
		ix.is_padded,
		ix.is_disabled,
		ix.is_hypothetical,		
		ix.allow_row_locks,
		ix.allow_page_locks,
		ix.filter_definition
from sys.indexes as ix
join sys.data_spaces as ds on ds.data_space_id = ix.data_space_id
GO
grant select on dbatools.v_indexes to public
go

-- Расширенное представление по индексам со статистикой использования индекса
--------------------
if object_id(N'dbatools.v_indexes_usage_stats',N'V') is not null
	drop view dbatools.v_indexes_usage_stats;
go
create view [dbatools].[v_indexes_usage_stats]
as
select 
		ix.schema_id,		
		ix.schema_name,
		ix.object_id,
		ix.object_name,
		ix.index_id,
		ix.index_name,
		ix.type,
		ix.type_desc,
		ix.is_unique,
		ix.data_space_id,
		ix.data_space,
		ix.part_count,
		ix.ignore_dup_key,
		ix.is_primary_key,
		ix.is_unique_constraint,
		ix.fill_factor,
		ix.is_padded,
		ix.is_disabled,
		ix.is_hypothetical,		
		ix.allow_row_locks,
		ix.allow_page_locks,
		ix.filter_definition,
		iu.user_seeks,
		iu.user_scans,
		iu.user_lookups,
		iu.system_seeks,
		iu.system_scans,
		iu.system_lookups	
from dbatools.v_indexes as ix
join sys.dm_db_index_usage_stats as iu on iu.index_id = ix.index_id and iu.object_id = ix.object_id and iu.database_id = DB_ID()
GO
grant select on dbatools.v_indexes_usage_stats to public
go		

-- Представление о просмотре функций секционирования и параметров
------------------------------------------------------------------
if object_id(N'dbatools.v_partition_scheme_info',N'V') is not null
	drop view dbatools.v_partition_scheme_info;
go
create view dbatools.v_partition_scheme_info 
as
select 
		prtsch.data_space_id as [DATA_SPACE_ID],
		prtsch.name as [SCHEME_NAME],
		prtfn.name as [FUNC_NAME],
		prtfn.fanout as [FUNC_PART],
		TYPE_NAME(prtpar.user_type_id) as [TYPE],
		prtrange.boundary_id as [RANGE_BOUNDARY],
		prtrange.value as [RANGE_VALUE]
from sys.partition_schemes as prtsch
	join sys.partition_functions as prtfn on prtfn.function_id = prtsch.function_id
	join sys.partition_parameters as prtpar on prtpar.function_id = prtfn.function_id
	join sys.partition_range_values as prtrange on prtrange.function_id = prtfn.function_id	
go
grant select on dbatools.v_partition_scheme_info to public
go

-- Представление о просмотре информации по файлам данных 
-- и журналу транзакций (размер файла/ Занято / Свободно)
----------------------------------------------------------
if OBJECT_ID(N'dbatools.v_show_free_spacedata_all',N'V') is not null
	drop view dbatools.v_show_free_spacedata_all
go

create view [dbatools].[v_show_free_spacedata_all] 
as
WITH spaceused as(
select
	a.FILEID,
	[FILE_SIZE_MB] = 
		convert(decimal(12,3),round(a.size/128.000,3)),
	[SPACE_USED_MB] =
		convert(decimal(12,3),round(fileproperty(a.name,'SpaceUsed')/128.000,3)),
	[FREE_SPACE_MB] =
		convert(decimal(12,3),round((a.size-fileproperty(a.name,'SpaceUsed'))/128.000,3)) ,
	[GROWTH_MB] =	convert(decimal(12,3),round(a.growth/128.000,3)),
	NAME = left(a.NAME,128),
	FILENAME = left(a.FILENAME,520),
    FILE_GROUP = fg.name,
	STATE_DESC = df.state_desc,
	[DEFAULT] = fg.is_default 
from
	sys.sysfiles a
left join sys.database_files df on df.file_id = a.fileid
left join sys.filegroups as fg on fg.data_space_id =  df.data_space_id
) 
select 
	FILEID, 
	FILE_SIZE_MB,
	SPACE_USED_MB,
	CAST(((spaceused.SPACE_USED_MB*1.0)/spaceused.FILE_SIZE_MB)*100 AS DECIMAL(5,2)) AS UsePercent,
	FREE_SPACE_MB,
	CAST(((spaceused.FREE_SPACE_MB*1.0)/spaceused.FILE_SIZE_MB)*100 AS DECIMAL(5,2)) AS FreePercent,
	[GROWTH_MB],
	[NAME],
	[FILENAME],
	FILE_GROUP,
	[STATE_DESC],
	[DEFAULT]
 from spaceused
union all
select	
	NULL as FILEID,
	sum(FILE_SIZE_MB)as FILE_SIZE_MB, 
	sum(SPACE_USED_MB)as SPACE_USED_MB,
	CAST(AVG(((spaceused.SPACE_USED_MB*1.0)/spaceused.FILE_SIZE_MB)*100) AS DECIMAL(5,2)) AS UsePercent,
	sum(FREE_SPACE_MB)as FREE_SPACE_MB,
	CAST(AVG(((spaceused.FREE_SPACE_MB*1.0)/spaceused.FILE_SIZE_MB)*100) AS DECIMAL(5,2)) AS UsePercent,
	null,
	NULL as [NAME],
	NULL as [FILENAME],
	'ONLINE' as [STATE_DESC],
	NULL as FILE_GROUP,
	NULL as [DEFAULT]
from spaceused
GO

grant select on dbatools.v_show_free_spacedata_all to public
go

-- табличная функция о просмотре кластерных индексов,
-- которые рекомендуется (необходимо) перестроить
-------------------------------------------------------
if OBJECT_ID(N'dbatools.fn_cluster_index_for_smart_rebuild') IS NOT NULL
	drop function dbatools.fn_cluster_index_for_smart_rebuild;
GO
create function dbatools.fn_cluster_index_for_smart_rebuild(
@min_page_count bigint = 8,
@max_page_count bigint = 9223372036854775807,
@avg_per float = 10.00
)returns table 
as return
select 
	quotename(OBJECT_SCHEMA_NAME(st.object_id,st.database_id)) + '.' + quotename(object_name(st.object_id)) as obj_name,
	quotename(i.index_name) as idx_name,
	st.avg_fragmentation_in_percent,
	i.allow_page_locks,
	case i.part_count when 0 then 0 else st.partition_number end as part_number,
	st.page_count,
	i.[type]
from dbatools.v_indexes i 
join master.sys.dm_db_index_physical_stats(db_id(),null,null,null,'LIMITED') st on st.object_id = i.object_id and  st.index_id = i.index_id 
where 
not exists (select * from dbatools.rep_service_index_exclude where obj_id = i.object_id and idx_id = i.index_id)
and i.is_disabled = 0 
and i.index_id = 1
and st.page_count > @min_page_count
and st.page_count <= @max_page_count
and	st.avg_fragmentation_in_percent >= @avg_per
GO
grant select on dbatools.fn_cluster_index_for_smart_rebuild to public
GO

-- табличная функция о просмотре не кластерных индексов,
-- которые рекомендуется (необходимо) перестроить
--------------------------------------------------------
if OBJECT_ID(N'dbatools.fn_index_for_smart_rebuild') IS NOT NULL
	drop function dbatools.fn_index_for_smart_rebuild;
GO
create function dbatools.fn_index_for_smart_rebuild(
@min_page_count bigint = 8,
@max_page_count bigint = 9223372036854775807,
@avg_per float = 10.00
)returns table 
as return
select 
	quotename(OBJECT_SCHEMA_NAME(st.object_id,st.database_id)) + '.' + quotename(object_name(st.object_id)) as obj_name,
	quotename(i.index_name) as idx_name,
	st.avg_fragmentation_in_percent,
	i.allow_page_locks,
	case i.part_count when 0 then 0 else st.partition_number end as part_number,
	st.page_count,
	i.[type]
from dbatools.v_indexes i 
join master.sys.dm_db_index_physical_stats(db_id(),null,null,null,'LIMITED') st on st.object_id = i.object_id and  st.index_id = i.index_id 
where 
not exists (select * from dbatools.rep_service_index_exclude where obj_id = i.object_id and idx_id = i.index_id)
and i.is_disabled = 0 
and i.index_id > 1
and st.page_count > @min_page_count
and st.page_count <= @max_page_count
and	st.avg_fragmentation_in_percent >= @avg_per
GO
grant select on dbatools.fn_index_for_smart_rebuild to public
GO

-- процедура по перестроению кластерных индексов
----------------------------------------------------
if object_id('dbatools.sp_smart_cluster_reindex',N'P') is not null
	drop procedure dbatools.sp_smart_cluster_reindex;
go
create procedure dbatools.sp_smart_cluster_reindex	
(
@min_page_count bigint = 8,
@max_page_count bigint = 9223372036854775807,
@avg_per float = 10.00,
@is_online bit = 0,
@debug_info bit = 0
)
as
declare 
		@lp_object_name			nvarchar(514),
		@lp_index_name			sysname,
		@lp_allow_page_locks	bit,
		@lp_avg_defrag_percent	decimal(10,3),
		@run_sql				nvarchar(1024),
		@oper_num				bigint,
		@ident					bigint,
		@oper_type				smallint,
		@part_numb				int,
		@page_count				bigint,
		@idx_type				tinyint

declare c1 INSENSITIVE cursor for 

with ste (table_name,idx_name,part_numb,avg_frag_per,avg_page_count) as(
select 
	r.table_name,r.idx_name,r.part_numb, p.avg_frag_in_per,p.avg_page_count
from (select distinct table_name,idx_name,part_numb from dbatools.rep_service_index) r
cross apply(
	select cast(avg(t.frag_per) as decimal(5,2)) as avg_frag_in_per, avg(t.pagcount) as avg_page_count
	from (
		select 	top 3
			fragmentation_in_percent as frag_per, 
			page_count as pagcount			
		from dbatools.rep_service_index
		where table_name = r.table_name and idx_name = r.idx_name and part_numb = r.part_numb
		order by start_time desc
		)t
)p
)
select 
	s.obj_name,
	s.idx_name,
	s.avg_fragmentation_in_percent,
	s.allow_page_locks,
	s.part_number,
	s.page_count,
	s.[type]	 	
from dbatools.fn_cluster_index_for_smart_rebuild(@min_page_count,@max_page_count,@avg_per) s
left join ste q on	q.table_name  = s.obj_name  
							and q.idx_name = s.idx_name 
							and q.part_numb  = s.part_number
where 							
	cast(abs(s.avg_fragmentation_in_percent - isnull(q.avg_frag_per,0.00)) as decimal(5,2)) > 1.00 --abs_frag_per
and	abs(s.page_count - isnull(q.avg_page_count,0)) > 1 -- abs_count_page	

open c1
FETCH NEXT FROM c1
	INTO @lp_object_name,@lp_index_name,@lp_avg_defrag_percent,@lp_allow_page_locks,@part_numb,@page_count,@idx_type
	
if @@rowcount > 0 
	select @oper_num = next value for dbatools.service_index	

else begin
close c1
deallocate c1
return 0
end	

set nocount on

WHILE @@FETCH_STATUS = 0
BEGIN
if @lp_avg_defrag_percent < 30
begin
 if @lp_allow_page_locks = 1 begin
	set @run_sql = N'ALTER INDEX '+ @lp_index_name + N' ON '+@lp_object_name + N'  REORGANIZE ';
	set @oper_type = 10;
 end else begin
	set @run_sql = N'ALTER INDEX '+ @lp_index_name + N' ON '+@lp_object_name + N'  REBUILD ';	
	set @oper_type = 11;
 end
end else if @lp_avg_defrag_percent >= 30 begin
		set @run_sql = N'ALTER INDEX '+ @lp_index_name + N' ON '+@lp_object_name + N'  REBUILD ';
		set @oper_type = 11;
end

if @part_numb > 0
	set @run_sql = @run_sql + ' PARTITION = '+CAST(@part_numb as nvarchar(12));

if SERVERPROPERTY('EngineEdition') = 3 and @idx_type = 1 and (@lp_avg_defrag_percent >= 30 or( @lp_avg_defrag_percent < 30 and @lp_allow_page_locks = 0)) and @is_online = 1
	set @run_sql = @run_sql + N' WITH (ONLINE = ON) '

if @debug_info = 1 begin
	print N'Index params :'
	print N'	Object: '+@lp_object_name
	print N'	Index: '+@lp_index_name
	print N'	Page count: '+ cast (@page_count as nvarchar)
	print N'	Partition: '+cast (@part_numb as nvarchar)
	print N'	Allow page lock: '+cast (@lp_allow_page_locks as nvarchar)
	print N'	Index type: '+cast (@idx_type as nvarchar)
	print N'	Fragmentation (%): '+cast (@lp_avg_defrag_percent as nvarchar)
	print N'Executing: '+ @run_sql
	end
begin try
		if @debug_info = 1
		print N'Add log info.'
	insert into dbatools.rep_service_index(table_name,idx_name,start_time,end_time,oper_num,oper_type,fragmentation_in_percent,page_count,part_numb) 
		values (@lp_object_name,@lp_index_name,getdate(),null,@oper_num,@oper_type,@lp_avg_defrag_percent,@page_count,@part_numb) 
		set @ident = Scope_identity()

	exec sp_executesql @run_sql
	if @debug_info = 1
		print N'Executing: Complite!'
	update dbatools.rep_service_index
		set end_time = getdate()
	where	record_id = @ident
		if @debug_info = 1
		print N'Update Info: Complite!'

end try
begin catch
if @debug_info = 1
		print N'Update Info: ERROR!'
update dbatools.rep_service_index
	set [description] = @run_sql
where	record_id = @ident
if @debug_info = 1
		print N'Add error log info.'
insert into dbatools.rep_errors(record_id,[error_message]) values (@ident,error_message())
if @debug_info = 1 
		print N'ERROR_MESSAGE: '+error_message()		
end catch

FETCH NEXT FROM c1
	INTO @lp_object_name,@lp_index_name,@lp_avg_defrag_percent,@lp_allow_page_locks,@part_numb,@page_count,@idx_type
END
CLOSE c1;
DEALLOCATE c1;
go
grant execute on dbatools.sp_smart_cluster_reindex to public;
GO

-- процедура по перестроению не кластерных индексов
----------------------------------------------------
if object_id('dbatools.sp_smart_reindex',N'P') is not null
	drop procedure dbatools.sp_smart_reindex;
go
create procedure dbatools.sp_smart_reindex	
(
@min_page_count bigint = 8,
@max_page_count bigint = 9223372036854775807,
@avg_per float = 10.00,
@is_online bit = 0,
@debug_info bit = 0
)
as
declare 
		@lp_object_name			nvarchar(514),
		@lp_index_name			sysname,
		@lp_allow_page_locks	bit,
		@lp_avg_defrag_percent	decimal(10,3),
		@run_sql				nvarchar(1024),
		@oper_num				bigint,
		@ident					bigint,
		@oper_type				smallint,
		@part_numb				int,
		@page_count				bigint,
		@idx_type				tinyint
		
declare c1 INSENSITIVE cursor for 

with ste (table_name,idx_name,part_numb,avg_frag_per,avg_page_count) as(
select 
	r.table_name,r.idx_name,r.part_numb, p.avg_frag_in_per,p.avg_page_count
from (select distinct table_name,idx_name,part_numb from dbatools.rep_service_index) r
cross apply(
	select cast(avg(t.frag_per) as decimal(5,2)) as avg_frag_in_per, avg(t.pagcount) as avg_page_count
	from (
		select 	top 3
			fragmentation_in_percent as frag_per, 
			page_count as pagcount			
		from dbatools.rep_service_index
		where table_name = r.table_name and idx_name = r.idx_name and part_numb = r.part_numb
		order by start_time desc
		)t
)p
)
select 
	s.obj_name,
	s.idx_name,
	s.avg_fragmentation_in_percent,
	s.allow_page_locks,
	s.part_number,
	s.page_count,
	s.[type]
from dbatools.fn_index_for_smart_rebuild(@min_page_count,@max_page_count,@avg_per) s
left join ste q on	q.table_name  = s.obj_name  
							and q.idx_name = s.idx_name 
							and q.part_numb  = s.part_number
where 							
	cast(abs(s.avg_fragmentation_in_percent - isnull(q.avg_frag_per,0.00)) as decimal(5,2)) > 1.00 --abs_frag_per
and	abs(s.page_count - isnull(q.avg_page_count,0)) > 1 -- abs_count_page	

open c1
FETCH NEXT FROM c1
	INTO @lp_object_name,@lp_index_name,@lp_avg_defrag_percent,@lp_allow_page_locks,@part_numb,@page_count,@idx_type

if @@rowcount > 0 	
	select @oper_num = next value for dbatools.service_index

else begin
close c1
deallocate c1
return 0
end	

set nocount on

WHILE @@FETCH_STATUS = 0
BEGIN
if @lp_avg_defrag_percent < 30
begin
 if @lp_allow_page_locks = 1 begin
	set @run_sql = N'ALTER INDEX '+ @lp_index_name + N' ON '+@lp_object_name + N'  REORGANIZE ';
	set @oper_type = 10;
 end else begin
	set @run_sql = N'ALTER INDEX '+ @lp_index_name + N' ON '+@lp_object_name + N'  REBUILD ';	
	set @oper_type = 11;
 end
end else if @lp_avg_defrag_percent >= 30 begin
		set @run_sql = N'ALTER INDEX '+ @lp_index_name + N' ON '+@lp_object_name + N'  REBUILD ';
		set @oper_type = 11;
end

if @part_numb > 0
	set @run_sql = @run_sql + ' PARTITION = '+CAST(@part_numb as nvarchar(12));

if SERVERPROPERTY('EngineEdition') = 3 and @idx_type = 2 and (@lp_avg_defrag_percent >= 30 or( @lp_avg_defrag_percent < 30 and @lp_allow_page_locks = 0)) and @is_online = 1 
	set @run_sql = @run_sql + N' WITH (ONLINE = ON) '

if @debug_info = 1 begin
	print N'Index params :'
	print N'	Object: '+@lp_object_name
	print N'	Index: '+@lp_index_name
	print N'	Page count: '+ cast (@page_count as nvarchar)
	print N'	Partition: '+cast (@part_numb as nvarchar)
	print N'	Allow page lock: '+cast (@lp_allow_page_locks as nvarchar)
	print N'	Index type: '+cast (@idx_type as nvarchar)
	print N'	Fragmentation (%): '+cast (@lp_avg_defrag_percent as nvarchar)
	print N'Executing: '+ @run_sql
	end
	
begin try
	if @debug_info = 1
		print N'Add log info.'
		
	insert into dbatools.rep_service_index(table_name,idx_name,start_time,end_time,oper_num,oper_type,fragmentation_in_percent,page_count,part_numb) 
		values (@lp_object_name,@lp_index_name,getdate(),null,@oper_num,@oper_type,@lp_avg_defrag_percent,@page_count,@part_numb) 
		set @ident = Scope_identity()

	exec sp_executesql @run_sql
if @debug_info = 1
		print N'Executing: Complite!'
	
	update dbatools.rep_service_index
		set end_time = getdate()
	where	record_id = @ident
	if @debug_info = 1
		print N'Update Info: Complite!'
end try
begin catch
if @debug_info = 1
		print N'Update Info: ERROR!'
update dbatools.rep_service_index
	set [description] = @run_sql
where	record_id = @ident
if @debug_info = 1
		print N'Add error log info.'
insert into dbatools.rep_errors(record_id,[error_message]) values (@ident,error_message())
if @debug_info = 1 
		print N'ERROR_MESSAGE: '+error_message()		
end catch
FETCH NEXT FROM c1
	INTO @lp_object_name,@lp_index_name,@lp_avg_defrag_percent,@lp_allow_page_locks,@part_numb,@page_count,@idx_type
END
CLOSE c1;
DEALLOCATE c1;
go
grant execute on dbatools.sp_smart_reindex to public;
GO

-- Представление о просмотре времени затраченному на
-- обслуживание индекса
-------------------------------------------------------------
if OBJECT_ID(N'dbatools.v_date_diff_last_smart_reindex',N'V') is not null
	drop view dbatools.v_date_diff_last_smart_reindex;
go
create view dbatools.v_date_diff_last_smart_reindex 
as
select 
	oper_num,	
	min(start_time) as date_min,
	max(end_time) as date_max,
	(max(end_time)-min(start_time)) as date_diff
	from dbatools.rep_service_index
where oper_type  in (10,11)
group by oper_num
go
grant select on dbatools.v_date_diff_last_smart_reindex to public
go

-- Процедура по очистки устаревших записей 
-- в таблице dbatools.rep_service_index
-------------------------------------------
if OBJECT_ID(N'dbatools.sp_clear_expired_smart_reindex',N'P') is not null
	drop procedure dbatools.sp_clear_expired_smart_reindex;
go
create procedure [dbatools].[sp_clear_expired_smart_reindex]
as
begin
set nocount on
declare @days int
declare @TmpSmartIndex table (record_id bigint);
select @days = value_int from dbatools.sys_params where [param] = N'ExpiredDays_smart_reindex'
insert into @TmpSmartIndex
select record_id 
from dbatools.rep_service_index
where oper_num in (
select distinct oper_num from dbatools.rep_service_index
where start_time < dateadd(dd,@days,getdate()) and oper_type in (10,11)
)
if exists(select * from @TmpSmartIndex)
begin
	begin tran
	begin try		
		delete from dbatools.rep_service_index where record_id in (select record_id from @TmpSmartIndex)
	commit tran
	end try
	begin catch
		rollback tran
	 DECLARE @ErrorMessage NVARCHAR(4000);
	 DECLARE @ErrorSeverity INT;
	 DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
	end catch
end
end
GO
if not exists (select * from  dbatools.sys_params where [param] = N'ExpiredDays_smart_reindex')
	insert into dbatools.sys_params([param],value_int)  values (N'ExpiredDays_smart_reindex',-90);
GO
