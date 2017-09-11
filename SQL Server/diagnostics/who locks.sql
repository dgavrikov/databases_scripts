SELECT s.session_id, DB_NAME(s.database_id) AS DBName,s.login_name ,s.host_name,s.program_name,s.host_process_id
,s.open_transaction_count,s.status
,r.blocking_session_id,r.last_wait_type,r.wait_resource,r.command,t.text
,pl.query_plan
FROM sys.dm_exec_sessions s
left join sys.dm_exec_requests r
	on s.session_id = r.session_id 
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t
OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) pl
WHERE
	r.blocking_session_id > 0 
OR s.session_id IN (
	SELECT blocking_session_id
	FROM sys.dm_exec_requests 
	WHERE blocking_session_id > 0
	);
	