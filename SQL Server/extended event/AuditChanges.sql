create event session [AuditChanges] on server 
add event sqlserver.object_altered(set collect_database_name=(1)
    action(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.is_system,sqlserver.nt_username,sqlserver.server_principal_name,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.session_server_principal_name,sqlserver.sql_text)
    where ([package0].[not_equal_uint64]([database_id],(2)) and [package0].[not_equal_binary_data]([sqlserver].[server_principal_sid],0x0105000000000005150000000848146EDD64B6535259C1170C040000) and [object_type]<>(21587))),
add event sqlserver.object_created(set collect_database_name=(1)
    action(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.is_system,sqlserver.nt_username,sqlserver.server_principal_name,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.session_server_principal_name,sqlserver.sql_text)
    where ([package0].[not_equal_uint64]([database_id],(2)) and [package0].[not_equal_binary_data]([sqlserver].[server_principal_sid],0x0105000000000005150000000848146EDD64B6535259C1170C040000) and [object_type]<>(21587))),
add event sqlserver.object_deleted(set collect_database_name=(1)
    action(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.is_system,sqlserver.nt_username,sqlserver.server_principal_name,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.session_server_principal_name,sqlserver.sql_text)
    where ([package0].[not_equal_uint64]([database_id],(2)) and [package0].[not_equal_binary_data]([sqlserver].[server_principal_sid],0x0105000000000005150000000848146EDD64B6535259C1170C040000) and [object_type]<>(21587))) 
add target package0.event_file(set filename=N'D:\MSSQL\Audit\AuditChanges',max_file_size=(1000),max_rollover_files=(25))
with (max_memory=102400 kb,event_retention_mode=allow_multiple_event_loss,max_dispatch_latency=60 seconds,max_event_size=0 kb,memory_partition_mode=per_node,track_causality=on,startup_state=on)
go


