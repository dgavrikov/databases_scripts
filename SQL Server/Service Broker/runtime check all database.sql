select 
'select '''+name+''', to_service_name, count(*), min(enqueue_time)
from '+name+'.sys.transmission_queue
GROUP BY to_service_name
order by 3'
,*
from sys.databases
where is_broker_enabled = 1
  and state_desc = 'ONLINE'