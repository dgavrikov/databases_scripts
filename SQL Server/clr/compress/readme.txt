[Info]
This assembly include two function for compress and decompress stream.
fnCompress - compress input stream and return compressed varbinary(max).
fnDecompress - decompress input stream and return decompressed varbinary(max).

[Install]
sp_configure 'advanced options',1;
GO
reconfigure with override;
GO
sp_configure 'clr enabled',1
GO
reconfigure with override;
GO

create assembly [DataCompression]
from 'c:\clr\DataCompression_x64.dll'
with permission_set = safe;
GO

create function dbo.fnCompress(@inputStream varbinary(max)) returns varbinary(max)
as external name DataCompression.DataCompression.fnCompress
GO

create function dbo.fnDecompress(@inputStream varbinary(max)) returns varbinary(max)
as external name DataCompression.DataCompression.fnDecompress
GO

--------
Examples
--------

declare @inputData nvarchar(4000);
declare @outData nvarchar(4000);
declare @cData varbinary(max)

select @inputData = replicate('Welcome!',500);
select datalength(@inputData) as [input DataLength],hashbytes('MD5',@inputData) as [Input HashMD5]

select @cData = dbo.fnCompress(cast(@inputData as varbinary(max)));
select datalength(@cData) as [compress DataLength],hashbytes('MD5',@cData) as [Compress HashMD5]

select @outData = cast(dbo.fnDecompress(@cData) as nvarchar(max));
select datalength(@outData) as [Output DataLength],hashbytes('MD5',@outData) as [Output HashMD5]

select iif(@outData = @inputData,'Equal','Not Equal') as Compare
GO