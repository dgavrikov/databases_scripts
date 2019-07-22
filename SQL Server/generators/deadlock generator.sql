set nocount on

if object_id('DeadlockTest') is not null
    drop table DeadlockTest

create table DeadlockTest
(
    Deadlock_Key int primary key clustered,
    Deadlock_Count int
)
go

if exists (select * from sysobjects where id = object_id(N'sp_simulatedeadlock')
           AND objectproperty(id, N'IsProcedure') = 1)
drop procedure sp_simulatedeadlock
GO

create procedure sp_simulatedeadlock
(
    @MaxDeadlocks int = -1 -- specify the number of deadlocks you want; -1 = constant deadlocking
)
as begin

    set nocount on

    if object_id('DeadlockTest') is null
        return

    -- Volunteer to be a deadlock victim.
    set deadlock_priority low

    declare @DeadlockCount int

    select @DeadlockCount = Deadlock_Count -- this starts at 0
    from DeadlockTest
    where Deadlock_Key = 2

    -- Trace the start of each deadlock event.
    -- To listen to the trace event, setup a SQL Server Profiler trace with event class "UserConfigurable:0".
    -- Note that the user running this proc must have ALTER TRACE permission.
    -- Also note that there are only 128 characters allowed in the trace text.
    declare @trace nvarchar(128)

    if @MaxDeadlocks > 0 AND @DeadlockCount > @MaxDeadlocks
    begin

        set @trace = N'Deadlock Test @MaxDeadlocks: ' + cast(@MaxDeadlocks as nvarchar) + N' @DeadlockCount: ' + cast(@DeadlockCount as nvarchar) + N' Resetting deadlock count.  Will not cause deadlock.'
        exec sp_trace_generateevent
            @eventid = 82,  -- 82 = UserConfigurable:0 through 91 = UserConfigurable:9
            @userinfo = @trace

        -- Reset the number of deadlocks.
        -- Hopefully if there is an outer transaction, it will complete and persist this change.
        update DeadlockTest
        set Deadlock_Count = 0
        where Deadlock_Key = 2
        return
    end

    set @trace = N'Deadlock Test @MaxDeadlocks: ' + cast(@MaxDeadlocks as nvarchar) + N' @DeadlockCount: ' + cast(@DeadlockCount as nvarchar) + N' Simulating deadlock.'
    exec sp_trace_generateevent
        @eventid = 82,  -- 82 = UserConfigurable:0 through 91 = UserConfigurable:9
        @userinfo = @trace

    declare @StartedTransaction bit
    set @StartedTransaction = 0
    if @@trancount = 0
    begin
        set @StartedTransaction = 1
        begin transaction
    end

    -- lock 2nd record
    update DeadlockTest
    set Deadlock_Count = Deadlock_Count
    from DeadlockTest
    where Deadlock_Key = 2

    -- lock 1st record to cause deadlock
    update DeadlockTest
    set Deadlock_Count = Deadlock_Count
    from DeadlockTest
    where Deadlock_Key = 1

    if @StartedTransaction = 1
        rollback    
end
go

insert into DeadlockTest(Deadlock_Key, Deadlock_Count)
select 1, 0
union select 2, 0

-- Force other processes to be the deadlock victim.
set deadlock_priority high

begin transaction

while 1 = 1
begin

    begin try

        begin transaction

        -- lock 1st record
        update DeadlockTest
        set Deadlock_Count = Deadlock_Count
        from DeadlockTest
        where Deadlock_Key = 1

        waitfor delay '00:00:10'

        -- lock 2nd record (which will be locked when the target proc calls sp_simulatedeadlock)
        update DeadlockTest
        set Deadlock_Count = Deadlock_Count
        from DeadlockTest
        where Deadlock_Key = 2

        rollback

    end try
    begin catch
        print 'Error ' + convert(varchar(20), ERROR_NUMBER()) + ': ' + ERROR_MESSAGE()
        goto cleanup
    end catch

end

cleanup:

if @@trancount > 0
    rollback

drop procedure sp_simulatedeadlock
drop table DeadlockTest