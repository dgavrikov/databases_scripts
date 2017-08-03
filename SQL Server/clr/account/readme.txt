[Info]
/// Calculate account checksum for provided account number and bic
/// ПОРЯДОК РАСЧЕТА КОНТРОЛЬНОГО КЛЮЧА В НОМЕРЕ ЛИЦЕВОГО СЧЕТА (ЦЕНТРАЛЬНЫЙ БАНК РОССИИ, 8 сентября 1997 г. N 515)
CalculateAccountChecksum 

/// Check is the string is a valid account number according to
/// ПОРЯДОК РАСЧЕТА КОНТРОЛЬНОГО КЛЮЧА В НОМЕРЕ ЛИЦЕВОГО СЧЕТА (ЦЕНТРАЛЬНЫЙ БАНК РОССИИ, 8 сентября 1997 г. N 515)
IsValidAccountNumber
	
[Install]
sp_configure 'advanced options',1;
GO
reconfigure with override;
GO
sp_configure 'clr enabled',1
GO
reconfigure with override;
GO

create assembly [AccountChecksum]
from 'c:\clr\AccountChecksum_x64.dll'
with permission_set = safe;
GO

create function dbo.UnmaskBankAccount(@mask nvarchar(20),@bic nvarchar(9),@num int) returns nvarchar(50)
as external name [AccountChecksum].[AccountChecksum].UnmaskBankAccount
GO

create function dbo.CalculateAccountChecksum(@accountNumber nvarchar(20),@bic nvarchar(9),@bicIsRkc bit=false) returns int
as external name [AccountChecksum].[AccountChecksum].CalculateAccountChecksum
GO

create function dbo.IsValidAccountNumber(@accountNumber nvarchar(20),@bic nvarchar(9),@bicIsRkc bit=false) returns bit
as external name [AccountChecksum].[AccountChecksum].IsValidAccountNumber
GO

--------
Examples
--------

