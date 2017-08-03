-- Показывает задания, которые пересекаются по времени выполнения
use [msdb]
GO
with ste as(
select 
	jh.job_id,
	jh.step_id,
	convert(datetime,cast(jh.run_date as varchar(8)),112)+CONVERT(datetime,Tfull.T,108) as run_datetime,	
	convert(datetime,cast(jh.run_date as varchar(8)),112)+CONVERT(datetime,Tfull.T,108)+CONVERT(datetime,Tdfull.T,108) as end_datetime,
	CONVERT(datetime,Tdfull.T,108) as duration
from dbo.sysjobhistory as jh
cross apply(select T = right('00000'+cast(jh.run_time as varchar(6)),6))T
cross apply(select T = substring(T.T,1,2))Th
cross apply(select T = substring(T.T,3,2))Tm
cross apply(select T = substring(T.T,5,2))Ts
cross apply(select T = Th.T+':'+Tm.T+':'+Ts.T)Tfull
cross apply(select T = right('00000'+cast(jh.run_duration as varchar(6)),6))Td
cross apply(select T = substring(Td.T,1,2))Tdh
cross apply(select T = substring(Td.T,3,2))Tdm
cross apply(select T = substring(Td.T,5,2))Tds
cross apply(select T = Tdh.T+':'+Tdm.T+':'+Tds.T)Tdfull

where  jh.run_status = 1
and jh.step_id = 0 
)
SELECT ROW_NUMBER() over (partition by convert(varchar,a.run_datetime,112) order by a.run_datetime) as row_num,
	j.name as job_a,	
	a.step_id as job_a_step_id,
	a.run_datetime as job_a_runtime,
	a.end_datetime as job_a_endtime,
	a.duration as job_a_duration,	
	j0.name as job_b,
	a0.step_id as job_b_step_id,
	a0.run_datetime as job_b_runtime,
	a0.end_datetime as job_b_endtime,
	a0.duration as job_b_duration,
	a.job_id as job_a_id,
	a0.job_id as job_b_id
  FROM ste as a
  JOIN ste as a0    ON a.job_id <> a0.job_id
  join dbo.sysjobs as j on j.job_id = a.job_id
  join dbo.sysjobs as j0 on j0.job_id = a0.job_id
   AND a0.end_datetime >= a.run_datetime
   AND a.end_datetime >= a0.run_datetime
GO
