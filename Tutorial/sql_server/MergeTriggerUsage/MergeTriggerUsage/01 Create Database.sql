create database MergeTriggerSamples
GO

use [MergeTriggerSamples]
GO

create table dbo.MergeTbl (
Id int not null,
FName nvarchar(10) not null,
constraint PK_MergeTbl primary key (Id)
)
GO

create trigger trFI_MergeTbl on dbo.MergeTbl 
for insert as
begin
	declare @rc int, @i int;
	set @rc = @@ROWCOUNT;
	select @i = count(*) from inserted;
	set nocount on;
	print 'Trigger for insert rc='+cast(@rc as varchar);
	print 'Trigger for insert i='+cast(@i as varchar);

end 
GO

create trigger trFU_MergeTbl on dbo.MergeTbl 
for update as
begin
	declare @rc int, @i int,@d int;
	set @rc = @@ROWCOUNT;
	select @i = count(*) from inserted;
	select @d = count(*) from deleted;
	set nocount on;
	print 'Trigger for update rc='+cast(@rc as varchar);
	print 'Trigger for update i='+cast(@i as varchar);
	print 'Trigger for update d='+cast(@d as varchar);

end 
GO

create trigger trFD_MergeTbl on dbo.MergeTbl 
for delete as
begin
	declare @rc int, @d int;
	set @rc = @@ROWCOUNT;
	select @d = count(*) from deleted;
	set nocount on;
	print 'Trigger for deleted rc='+cast(@rc as varchar);
	print 'Trigger for deleted d='+cast(@d as varchar);

end 
GO

create trigger trAI_MergeTbl on dbo.MergeTbl 
after insert as
begin
	declare @rc int, @i int;
	set @rc = @@ROWCOUNT;
	select @i = count(*) from inserted;
	set nocount on;
	print 'Trigger after insert rc='+cast(@rc as varchar);
	print 'Trigger after insert i='+cast(@i as varchar);

end 
GO

create trigger trAU_MergeTbl on dbo.MergeTbl 
after update as
begin
	declare @rc int, @i int,@d int;
	set @rc = @@ROWCOUNT;
	select @i = count(*) from inserted;
	select @d = count(*) from deleted;
	set nocount on;
	print 'Trigger after update rc='+cast(@rc as varchar);
	print 'Trigger after update i='+cast(@i as varchar);
	print 'Trigger after update d='+cast(@d as varchar);

end 
GO

create trigger trAD_MergeTbl on dbo.MergeTbl 
after delete as
begin
	declare @rc int, @d int;
	set @rc = @@ROWCOUNT;
	select @d = count(*) from deleted;
	set nocount on;
	print 'Trigger after deleted rc='+cast(@rc as varchar);
	print 'Trigger after deleted d='+cast(@d as varchar);

end 
GO

create trigger trFAll_MergeTbl on dbo.MergeTbl 
for insert,update,delete as
begin
	declare @rc int, @i int,@d int;
	set @rc = @@ROWCOUNT;
	select @i = count(*) from inserted;
	select @d = count(*) from deleted;
	set nocount on;
	print 'Trigger for all rc='+cast(@rc as varchar);
	print 'Trigger for all i='+cast(@i as varchar);
	print 'Trigger for all d='+cast(@d as varchar);

end 
GO

create trigger trAAll_MergeTbl on dbo.MergeTbl 
after insert,update,delete as
begin
	declare @rc int, @i int,@d int;
	set @rc = @@ROWCOUNT;
	select @i = count(*) from inserted;
	select @d = count(*) from deleted;
	set nocount on;
	print 'Trigger after all rc='+cast(@rc as varchar);
	print 'Trigger after all i='+cast(@i as varchar);
	print 'Trigger after all d='+cast(@d as varchar);
end 
GO

