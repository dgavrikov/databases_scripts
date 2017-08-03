SELECT spid,DB_NAME(p.dbid) AS DBName,p.blocked,p.lastwaittype,p.waitresource,p.open_tran,p.status,p.cmd,t.text,pl.query_plan,p.hostname,p.program_name,p.hostprocess
FROM sys.sysprocesses p
LEFT JOIN sys.dm_exec_requests r ON r.session_id = p.spid
OUTER APPLY sys.dm_exec_sql_text(p.sql_handle) t
OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) pl
WHERE p.blocked > 0 
OR spid IN (
	SELECT p.blocked
	FROM sys.sysprocesses p
	WHERE p.blocked > 0
	)


