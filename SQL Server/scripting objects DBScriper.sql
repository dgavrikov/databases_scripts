select 'D:\Work\DBScripter\DBScripter.exe server='+cast(serverproperty('MachineName') as varchar)+' db='+name+' out=d:\Project\SQL\source\'
from sys.databases d
outer apply (
      select
            case when
                  d.state_desc = 'ONLINE'
                  and d.is_read_only = 0
                  and
                  (
                        hars.replica_id is null
                        or
                        (
                             hars.is_local = 1
                             and isnull(hars.[role], 3) = 1
                        )
                  )
                        then 1
                        else 0
            end [Status]
      from sys.dm_hadr_availability_replica_states hars 
      where d.database_id = iif(d.name is null, db_id(), db_id(d.name)) and d.replica_id = hars.replica_id

) wr
where name not in ('master','tempdb','msdb','model','SSISDB')
and isnull(wr.Status,1) = 1
order by name


