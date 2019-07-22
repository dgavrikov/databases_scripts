-- isnull is only MSSQL operatior. Use data type for first predicate
declare 
	@a tinyint = null,
	@b int = -1

select coalesce(@a,@b)
select isnull(@a,@b)
go

declare
	@a decimal(18,2) = null,
	@b decimal(22,4) = 1234.5678

select coalesce(@a,@b)
select isnull(@a,@b)
go
