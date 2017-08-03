Restore tlog from disk
declare 
	@path varchar(230),
	@run varchar(250),
	@flname varchar(255)
set @path = '\\bgfmskswdias1\tlog\' -- не забываем про черточку

if (object_id('tempdb..##RestoreTLog') is not null) drop table ##RestoreTLog
create table ##RestoreTLog (flname varchar(255))

set @run = 'dir '+@path+'*.trn /b /a:-d /o:n' 
insert into ##RestoreTLog
exec xp_cmdshell @run

declare c1 cursor 
	for select (@path+ltrim(rtrim(flname))) as flname from ##RestoreTLog where flname is not null

open c1    
FETCH NEXT FROM c1 into @flname  
WHILE @@FETCH_STATUS = 0  
BEGIN    
/***************************/
/*      тут обработка      */
/***************************/
RESTORE LOG [workdb] 
FROM  DISK = @flname 
WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 10
/***************************/

FETCH NEXT FROM c1 into @flname
END    

close c1  DEALLOCATE c1    

if (object_id('tempdb..##RestoreTLog') is not null) drop table ##RestoreTLog
