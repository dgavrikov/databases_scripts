-- обьем процедурного кеша в разрезе баз
SELECT db = DB_NAME(t.[dbid]), plan_cache_kb = SUM(size_in_bytes / 1024) 
FROM sys.dm_exec_cached_plans p
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) t
WHERE t.[dbid] < 32767
GROUP BY t.[dbid]
ORDER BY 2 DESC