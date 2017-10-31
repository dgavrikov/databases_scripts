create table dbo.t1 (
	id int not null,
	fname varchar(10) not null
)
GO
create unique clustered index ix_t1
on dbo.t1(id)
GO

create table dbo.t2(
id int not null,
pid int not null,
fname varchar(10) not null
)
GO
create unique clustered index ix_t2
on dbo.t2(id)
GO

alter table t2
add constraint FK_t2_t1_id foreign key(pid) references dbo.t1(id)
GO

insert into dbo.t1(id,fname)
values (1,'AAA');
GO

create table dbo.errorlog(
dt_insert	datetime2 not null default(sysdatetime()),
spid		int not null default(@@spid),
err_text	varchar(4000) not null
)
GO

set ansi_nulls on
go
set quoted_identifier on
go
create procedure dbo.proc_1
	@id		int,
	@pid	int,
	@fname	varchar(10)
as
begin
	declare @err_text varchar(4000)='';
	set nocount on;
	set xact_abort on;
	begin try
		insert into dbo.t2(id,pid,fname)
		values (@id,@pid,@fname);
	end try
	begin catch
		declare 
		@err_number		int				= error_number(),
		@err_message	varchar(2000)	= error_message(),
		@err_line		int				= error_line(),
		@err_proc		sysname			= error_procedure(),
		@err_severity	int				= error_severity(),
		@err_state		int				= error_state();

		set @err_text = 'Ошибка #'+isnull(cast(@err_number as varchar),'<null>')
						+ ' в процедуре ['+isnull(@err_proc,'<null>')+'] в строке #'
						+isnull(cast(@err_line as varchar),'<null>')+': '+isnull(@err_message,'<null>');
		
		if xact_state() in (-1,1) and @@trancount > 0
			rollback;
		insert dbo.errorlog(err_text) values (@err_text);

		raiserror(@err_text,@err_severity,@err_state);
	end catch
end
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure dbo.proc_main_proc
	@id		int,
	@pid	int,
	@fname	varchar(10)
as
begin
	declare @err_text varchar(4000)='';
	set nocount on;
	set xact_abort on;
	if @@trancount > 0
		save transaction TrSavePoint;
	begin try
		--exec dbo.proc_1 @id = 11, @pid = 1, @fname = @fname;
		exec dbo.proc_1 @id = @id, @pid = @pid, @fname = @fname;
	return 0;
	end try
	begin catch
		declare 
		@err_number		int				= error_number(),
		@err_message	varchar(2000)	= error_message(),
		@err_line		int				= error_line(),
		@err_proc		sysname			= error_procedure(),
		@err_severity	int				= error_severity(),
		@err_state		int				= error_state();

		set @err_text = 'Ошибка #'+isnull(cast(@err_number as varchar),'<null>')
						+ ' в процедуре ['+isnull(@err_proc,'<null>')+'] в строке #'
						+isnull(cast(@err_line as varchar),'<null>')+': '+isnull(@err_message,'<null>');
		
		if @@trancount > 0
			rollback transaction TrSavePoint;

		insert dbo.errorlog(err_text) values (@err_text);

		return 0;
	end catch
end
go
--------------------------------------------------------------------------------------------------------------

declare @id int = 2, @pid int = 2, @fname varchar(20) = 'SSSS';
--declare @id int = 1, @pid int = 1, @fname varchar(20) = 'SSSS';
declare @ret int = 0, @err_text varchar(2000);

begin try
	begin tran;
	exec @ret = dbo.proc_main_proc @id = @id, @pid = @pid, @fname = @fname;
	if @ret = 0 begin
		commit;
		print 'commit';
	end else begin
		rollback;
		print 'rollback';
	end;
end try
begin catch
declare 
		@err_number		int				= error_number(),
		@err_message	varchar(2000)	= error_message(),
		@err_line		int				= error_line(),
		@err_proc		sysname			= error_procedure(),
		@err_severity	int				= error_severity(),
		@err_state		int				= error_state();

		set @err_text = 'Ошибка #'+isnull(cast(@err_number as varchar),'<null>')
						+ ' в процедуре ['+isnull(@err_proc,'<null>')+'] в строке #'
						+isnull(cast(@err_line as varchar),'<null>')+': '+isnull(@err_message,'<null>');
		if @@trancount > 0
			if xact_state() = -1 begin
				rollback;
				print 'rollback';
			end else if xact_state() = 1 begin
				commit;
				print 'commit';
			end
end catch

select * from dbo.t1;
select * from dbo.t2;
select * from dbo.errorlog;

sp_recompile 'dbo.proc_main_proc'
sp_recompile 'dbo.proc_1'
