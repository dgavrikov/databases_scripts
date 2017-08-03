-- Поиск каталога / отчета по имени пользователя и права на него
select c.Path,c.Name,r.RoleName
from dbo.Users u
join dbo.PolicyUserRole pu on pu.UserID = u.UserID
join dbo.Catalog c on c.PolicyID = pu.PolicyID
join dbo.Roles r on r.RoleID = pu.RoleID
where u.UserName = 'Allow_Reporting_Service'
