declare @dbname nvarchar(128),
		@sqlrun nvarchar(1024),
		@path nvarchar(128),
		@backupSetId as int,
		@dbfile nvarchar(256)
declare c insensitive cursor for select [name] from sys.databases where [name] not in ('tempdb','master','msdb','model')
set @path = 'd:\base\backup\'
open c
fetch next from c into @dbname
while @@fetch_status = 0 
begin
set @sqlrun = 'BACKUP DATABASE ['+@dbname+'] TO  DISK = N'''+@path+@@servername+'_'+@dbname+'_'
				+replace(convert(nvarchar,getdate(),102),'.','_')+'.bak'' WITH NOFORMAT, INIT, NAME = N'''
				+@dbname+'-Full Database Backup'',SKIP, NOREWIND, NOUNLOAD,  STATS = 10'
exec sp_executesql @sqlrun
set @dbfile = @path+@@servername+'_'+@dbname+'_'+replace(convert(nvarchar,getdate(),102),'.','_')+'.bak'
select @backupSetId = position from msdb..backupset where database_name=@dbname and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=@dbname )
if @backupSetId is not null 
	RESTORE VERIFYONLY FROM  DISK = @dbfile WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
fetch next from c into @dbname
end
close c
deallocate c


SELECT 
'BACKUP DATABASE '+QUOTENAME(name)+ '
TO DISK = N''\\10.77.19.2\backup$\processing.backup\'+name+'_full.bak'' 
WITH INIT, COPY_ONLY, STATS=5
GO
'
FROM sys.databases
WHERE database_id > 4
