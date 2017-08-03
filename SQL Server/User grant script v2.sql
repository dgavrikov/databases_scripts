----------------------------------------------- Скриптование прав пользователя -----------------------------------------------------
declare   @loginName sysname = '@-DIRECT\smsmail'
		, @UserName sysname
		, @DatabaseName varchar(255)
		, @sql nvarchar(max)
		, @CommandExists bit 

DECLARE @SqlCommand TABLE (Id int Identity (1,1), SqlText varchar(8000))
DECLARE @SqlCommandResult TABLE (Id int Identity (1,1), SqlText varchar(8000))

declare curDB cursor for
/*  -- для всех баз
	select name
	from sys.databases  
	where source_database_id is null
	and state_desc = 'ONLINE'
	order by name
*/
--  только для БД, которые не являются вторичными репликами
	select db.name
	from sys.databases db	left join sys.dm_hadr_availability_replica_states hars
								on db.replica_id = hars.replica_id
	where hars.role_desc = 'PRIMARY'		
	or hars.role_desc is null
	and db.[state] = 0
	and db.source_database_id is null
	order by db.name

open curDB

fetch next from curDB
       into @DatabaseName

while @@fetch_status = 0
begin
       set @CommandExists = 0
       delete from @SqlCommand
       
       insert into @SqlCommand (SqlText) 
             select 'use '+ @DatabaseName

		set @SQL=  ( 'select @UserName =	name from ' + @DatabaseName + '.' + 'sys.sysusers
											where [sid] = (	select [sid] from sys.syslogins where name = ' + '''' + @loginName + '''' + ')'	)
	--	print(@sql)

		exec sp_executesql @sql, N'@UserName sysname out', @UserName out

       --заводим пользователя в БД
       insert into @SqlCommand (SqlText)       
       select 'if not exists(select name from sys.database_principals where type in (''S'',''U'') and name = '''+@UserName+''') 
       CREATE USER ['+@UserName+'] FOR LOGIN ['+@UserName+']'
             
       --включение в роли
       insert into @SqlCommand (SqlText) 
             select '-- включение в роли'
       set @SQL = 'use '+@DatabaseName+'
       declare @UserName varchar(255)
       set @UserName = '''+@UserName+'''
       SELECT 
       ''EXEC sp_addrolemember N''''''+b.name+'''''', N''''''+bm.name+''''''''
       FROM sys.database_role_members AS a 
             INNER JOIN sys.database_principals AS b ON a.role_principal_id = b.principal_id
             INNER JOIN sys.database_principals AS bm ON a.member_principal_id = bm.principal_id
       where bm.name =  @UserName'
       insert into @SqlCommand (SqlText)
       execute (@SQL)
       if @@rowcount>0 set @CommandExists = 1

       --права БД          
       insert into @SqlCommand (SqlText) 
             select '-- права БД'
       set @SQL = 
       'use '+@DatabaseName+'
       declare @UserName varchar(255)
       set @UserName = '''+@UserName+'''
       select 
             p.State_Desc+ '' '' 
             +Permission_Name  COLLATE Cyrillic_General_CI_AS  + '' TO [''+@UserName+'']'' as Sqltext
       from sys.database_permissions p
             inner join sys.sysusers u on u.uid=p.grantee_principal_id
       where class = 0
             and u.name = @UserName
       '
       insert into @SqlCommand (SqlText)
       execute (@SQL)
       if @@rowcount>0 set @CommandExists = 1
             
       --права на схемы
       insert into @SqlCommand (SqlText) 
             select '-- права схемы'
       set @SQL = 
       'use '+@DatabaseName+'
       declare @UserName varchar(255)
       set @UserName = '''+@UserName+'''
       select 
             p.State_Desc+ '' '' 
             +Permission_Name  COLLATE Cyrillic_General_CI_AS  + '' ON SCHEMA::[''
             +s.name+''] TO [''+@UserName+'']'' as Sqltext--,
       --o.type_desc, s.name, o.name, u.name as grantee,ug.name as grantor, * 
       from sys.database_permissions p
       inner join sys.schemas s on p.major_id=s.schema_id
       inner join sys.sysusers u on u.uid=p.grantee_principal_id
       inner join sys.sysusers ug on ug.uid=p.grantor_principal_id
       where class = 3
             and u.name = @UserName
       order by s.name
       '
       insert into @SqlCommand (SqlText)
       execute (@SQL)
       if @@rowcount>0 set @CommandExists = 1

       --права на объекты БД
       insert into @SqlCommand (SqlText) 
             select '-- права на объекты БД'
       set @SQL = 
       'use '+@DatabaseName+'
       declare @UserName varchar(255)
       set @UserName = '''+@UserName+'''
       select 
             p.State_Desc+ '' '' 
             +Permission_Name  COLLATE Cyrillic_General_CI_AS  + '' ON OBJECT::[''
             +s.name+''].[''
             +o.name 
             +''] TO [''+@UserName+'']'' as Sqltext--,
       --o.type_desc, s.name, o.name, u.name as grantee,ug.name as grantor, * 
       from sys.database_permissions p
       inner join sys.objects o on p.major_id=o.object_id
       inner join sys.schemas s on o.schema_id=s.schema_id
       inner join sys.sysusers u on u.uid=p.grantee_principal_id
       left join sys.sysusers ug on ug.uid=p.grantor_principal_id
       where class = 1
             and u.name = @UserName
       order by s.name, o.name
       '
       insert into @SqlCommand (SqlText)
       execute (@SQL)
       if @@rowcount>0 set @CommandExists = 1
       
       --Если были значимые команды то переносим в результирующую таблицу
       if @CommandExists = 1
       begin
             insert into @SqlCommandResult (SqlText)
             select SqlText from @SqlCommand order by Id
       end 

       fetch next from curDB
             into @DatabaseName
end 
close curDB
deallocate curDB
select * from @SqlCommandResult
