[Info]
This function return null if object is valid or return error message.

[Install]
USE [master]
GO
sp_configure 'clr enabled',1
GO
reconfigure with override
GO
alter database [test] set trustworthy on
GO
use [test]
GO

Create assembly [InvalidObjects]
from 'c:\SQL\clr\InvalidObject.dll'
WITH PERMISSION_SET = external_access;
GO

Create function dbo.GetInvalidObjectInfo(@object_id int,@dbName sysname,@serverName sysname=null)
returns nvarchar(max)
AS EXTERNAL NAME InvalidObjects.InvalidObjects.GetInvalidObjectInfo
GO

[Samples]
-- This script to use for find invalid object ib database.
select 
	 cast(schemaname as varchar(32)) [schema],
	 cast (name  as varchar(64)) name,
	 cast(type as varchar(12)) as [type],
	 err
	 ,'alter schema ['+schemaname+'_old] transfer '+quotename(schemaname)+'.'+quotename(name) as script -- script from transfer object to another schema.
from 
	 (select schema_name(schema_id) as schemaname,name,type,dbo.GetInvalidObjectInfo(object_id,db_name(),null) as err 
		  from sys.all_objects
		  where	 [type] in ('V','P','FN','TF','IF') -- Object type for scan
					 and name not like 'MSmerge_%' collate Cyrillic_General_CS_AS -- Exclude replica object (case sensivity)
					 and name not like 'sp_MSsync_%' collate Cyrillic_General_CS_AS -- Exclude replica object (case sensivity)
					 and name not like 'sp_MScft_%' collate Cyrillic_General_CS_AS -- Exclude replica object (case sensivity)
					 and schema_name(schema_id) not in ('sys') -- Exclude schema for scaning
	 )t 
where 
	 t.err is not null and -- Show only invalid object
	 t.err not like 'Invalid object name ''#%' and -- Exclude object with error like mask.
	 schemaname not like '%old' -- exclude schema to transfer object
order by 1,2
GO