/*
DBCC SHRINKFILE(2,500)
GO
*/
;
WITH spaceused as(
select
	a.FILEID,
	[FILE_SIZE_MB] = 
		convert(decimal(12,3),round(a.size/128.000,3)),
	[SPACE_USED_MB] =
		convert(decimal(12,3),round(fileproperty(a.name,'SpaceUsed')/128.000,3)),
	[FREE_SPACE_MB] =
		convert(decimal(12,3),round((a.size-fileproperty(a.name,'SpaceUsed'))/128.000,3)) ,
	[GROWTH_MB] =	convert(decimal(12,3),round(a.growth/128.000,3)),
	NAME = left(a.NAME,128),
	FILENAME = left(a.FILENAME,520),
    FILE_GROUP = fg.name,
	STATE_DESC = df.state_desc,
	[DEFAULT] = fg.is_default 
from
	sys.sysfiles a
left join sys.database_files df on df.file_id = a.fileid
left join sys.filegroups as fg on fg.data_space_id =  df.data_space_id
) 
select 
	FILEID, 
	FILE_SIZE_MB,
	SPACE_USED_MB,
	CAST(((spaceused.SPACE_USED_MB*1.0)/spaceused.FILE_SIZE_MB)*100 AS DECIMAL(5,2)) AS UsePercent,
	FREE_SPACE_MB,
	CAST(((spaceused.FREE_SPACE_MB*1.0)/spaceused.FILE_SIZE_MB)*100 AS DECIMAL(5,2)) AS FreePercent,
	[GROWTH_MB],
	[NAME],
	[FILENAME],
	FILE_GROUP,
	[STATE_DESC],
	[DEFAULT],
	'DBCC SHRINKFILE('+cast(FILEID as varchar) + ','+cast(cast(SPACE_USED_MB as int)+5 as varchar)+')
GO
' as ExecShrink
 from spaceused
union all
select	
	NULL as FILEID,
	sum(FILE_SIZE_MB)as FILE_SIZE_MB, 
	sum(SPACE_USED_MB)as SPACE_USED_MB,
	CAST(AVG(((spaceused.SPACE_USED_MB*1.0)/spaceused.FILE_SIZE_MB)*100) AS DECIMAL(5,2)) AS UsePercent,
	sum(FREE_SPACE_MB)as FREE_SPACE_MB,
	CAST(AVG(((spaceused.FREE_SPACE_MB*1.0)/spaceused.FILE_SIZE_MB)*100) AS DECIMAL(5,2)) AS UsePercent,
	null,
	NULL as [NAME],
	NULL as [FILENAME],
	'ONLINE' as [STATE_DESC],
	NULL as FILE_GROUP,
	NULL as [DEFAULT],
	NULL
from spaceused
ORDER BY [DEFAULT]DESC ,FILE_GROUP,FILEID
