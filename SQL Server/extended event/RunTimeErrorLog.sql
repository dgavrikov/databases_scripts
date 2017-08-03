create event session [RunTimeErrorLog] on server 
add event sqlserver.error_reported(
    action(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.server_principal_name,sqlserver.server_principal_sid,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.session_server_principal_name,sqlserver.sql_text,sqlserver.username)
    where ([package0].[not_equal_int64]([error_number],(156)) and [package0].[not_equal_int64]([error_number],(8153)) and [package0].[not_equal_int64]([error_number],(5703)) and [package0].[not_equal_int64]([error_number],(5701)) and [package0].[not_equal_int64]([error_number],(102)) and [package0].[greater_than_int64]([severity],(10)) and [package0].[less_than_int64]([error_number],(50000)) and [package0].[not_equal_int64]([error_number],(8152)) and [package0].[not_equal_int64]([error_number],(1222)))) 
add target package0.event_file(set filename=N'D:\MSSQL\Audit\RunTimeErrorLog',max_file_size=(100),max_rollover_files=(10))
with (max_memory=102400 kb,event_retention_mode=allow_multiple_event_loss,max_dispatch_latency=60 seconds,max_event_size=0 kb,memory_partition_mode=per_node,track_causality=on,startup_state=on)
go


