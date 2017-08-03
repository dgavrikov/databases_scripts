create event session [Deadlock_monitor] on server 
add event sqlserver.xml_deadlock_report(
    action(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.server_instance_name,sqlserver.server_principal_name,sqlserver.session_id,sqlserver.sql_text)) 
add target package0.event_file(set filename=N'D:\MSSQL\Audit\Deadlock_monitor.xel',max_file_size=(100)),
add target package0.ring_buffer(set max_events_limit=(0),max_memory=(4096))
with (max_memory=102400 kb,event_retention_mode=allow_multiple_event_loss,max_dispatch_latency=60 seconds,max_event_size=0 kb,memory_partition_mode=per_node,track_causality=on,startup_state=off)
go


