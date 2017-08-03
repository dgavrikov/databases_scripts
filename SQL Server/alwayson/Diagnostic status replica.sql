-- 1.	Диагностические запросы показывают, что все реплики в норме 
SELECT  r.replica_server_name
         , rs.database_id
      , DB_NAME(rs.database_id) AS [DatabaseName]
      , ISNULL(DATEDIFF(SECOND, rs.last_commit_time, prs.last_commit_time), 0) AS [SecsBehindPrimary]
      , prs.last_commit_time AS [Primary_last_commit_time]
      , rs.last_commit_time AS [Secondary_last_commit_time]
      , rs.last_redone_time AS [Secondary_last_redone_time]
FROM    sys.dm_hadr_database_replica_states rs
        JOIN sys.availability_replicas r ON r.group_id = rs.group_id
              AND r.replica_id = rs.replica_id
        JOIN sys.dm_hadr_database_replica_states prs ON r.group_id = prs.group_id
              AND prs.group_database_id = rs.group_database_id
              AND rs.is_local = 0
              AND prs.is_primary_replica = 1
--WHERE   DB_NAME(rs.database_id) = 'hell'
ORDER BY DB_NAME(rs.database_id), r.replica_server_name;

SELECT  rs.redo_queue_size, *
FROM    sys.dm_hadr_database_replica_states rs
        JOIN sys.availability_replicas r ON r.group_id = rs.group_id
                                            AND r.replica_id = rs.replica_id
WHERE  --rs.database_id = 13
        --AND r.replica_server_name = @@SERVERNAME
             rs.redo_queue_size IS NOT NULL;
