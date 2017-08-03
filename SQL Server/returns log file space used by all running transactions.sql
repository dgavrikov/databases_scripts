-- This query returns log file space used by all running transactions.
select
    SessionTrans.session_id as [SPID],
    enlist_count as [Active Requests],
    ActiveTrans.transaction_id as [ID],
    ActiveTrans.name as [Name],
    ActiveTrans.transaction_begin_time as [Start Time],
    case transaction_type
        when 1 then 'Read/Write'
        when 2 then 'Read-Only'
        when 3 then 'System'
        when 4 then 'Distributed'
        else 'Unknown - ' + convert(varchar(20), transaction_type)
    end as [Transaction Type],
    case transaction_state
        when 0 then 'Uninitialized'
        when 1 then 'Not Yet Started'
        when 2 then 'Active'
        when 3 then 'Ended (Read-Only)'
        when 4 then 'Committing'
        when 5 then 'Prepared'
        when 6 then 'Committed'
        when 7 then 'Rolling Back'
        when 8 then 'Rolled Back'
        else 'Unknown - ' + convert(varchar(20), transaction_state)
    end as 'State',
    case dtc_state
        when 0 then NULL
        when 1 then 'Active'
        when 2 then 'Prepared'
        when 3 then 'Committed'
        when 4 then 'Aborted'
        when 5 then 'Recovered'
        else 'Unknown - ' + convert(varchar(20), dtc_state)
    end as 'Distributed State',
    DB.Name as 'Database',
    database_transaction_begin_time as [DB Begin Time],
    case database_transaction_type
        when 1 then 'Read/Write'
        when 2 then 'Read-Only'
        when 3 then 'System'
        else 'Unknown - ' + convert(varchar(20), database_transaction_type)
    end as 'DB Type',
    case database_transaction_state
        when 1 then 'Uninitialized'
        when 3 then 'No Log Records'
        when 4 then 'Log Records'
        when 5 then 'Prepared'
        when 10 then 'Committed'
        when 11 then 'Rolled Back'
        when 12 then 'Committing'
        else 'Unknown - ' + convert(varchar(20), database_transaction_state)
    end as 'DB State',
    database_transaction_log_record_count as [Log Records],
    database_transaction_log_bytes_used / 1024 as [Log KB Used],
    database_transaction_log_bytes_reserved / 1024 as [Log KB Reserved],
    database_transaction_log_bytes_used_system / 1024 as [Log KB Used (System)],
    database_transaction_log_bytes_reserved_system / 1024 as [Log KB Reserved (System)],
    database_transaction_replicate_record_count as [Replication Records],
    command as [Command Type],
    total_elapsed_time as [Elapsed Time],
    cpu_time as [CPU Time],
    wait_type as [Wait Type],
    wait_time as [Wait Time],
    wait_resource as [Wait Resource],
    reads as [Reads],
    logical_reads as [Logical Reads],
    writes as [Writes],
    --open_transaction_count as [Open Transactions],
    open_resultset_count as [Open Result Sets],
    row_count as [Rows Returned],
    nest_level as [Nest Level],
    granted_query_memory as [Query Memory],
    SUBSTRING(SQLText.text,ExecReqs.statement_start_offset/2,(CASE WHEN ExecReqs.statement_end_offset = -1 then LEN(CONVERT(nvarchar(max), SQLText.text)) * 2 ELSE ExecReqs.statement_end_offset end - ExecReqs.statement_start_offset)/2) AS query_text
from
    sys.dm_tran_active_transactions ActiveTrans (nolock)
    inner join sys.dm_tran_database_transactions DBTrans (nolock)
        on DBTrans.transaction_id = ActiveTrans.transaction_id
    inner join sys.databases DB (nolock)
        on DB.database_id = DBTrans.database_id
    left join sys.dm_tran_session_transactions SessionTrans (nolock)
        on SessionTrans.transaction_id = ActiveTrans.transaction_id
    left join sys.dm_exec_requests ExecReqs (nolock)
        on ExecReqs.session_id = SessionTrans.session_id
        and ExecReqs.transaction_id = SessionTrans.transaction_id
    outer apply sys.dm_exec_sql_text(ExecReqs.sql_handle) AS SQLText
--where SessionTrans.session_id is not null -- comment this out to see SQL Server internal processes