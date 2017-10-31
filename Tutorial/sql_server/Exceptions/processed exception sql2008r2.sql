declare @str varchar(20)
declare @err_text varchar(4000)='';

begin try
	set xact_abort on;
	--select 1/0;
	raiserror ('Необходимо заполнить параметр %s',17,1,@str);
end try
begin catch
	declare 
		@err_number		int				= error_number(),
		@err_message	varchar(2000)	= error_message(),
		@err_line		int				= error_line(),
		@err_proc		sysname			= error_procedure(),
		@err_severity	int				= error_severity(),
		@err_state		int				= error_state();

		set @err_text = 'Ошибка #'+isnull(cast(@err_number as varchar),'<null>')
						+ ' в процедуре ['+isnull(@err_proc,'<null>')+'] в строке #'
						+isnull(cast(@err_line as varchar),'<null>')+': '+isnull(@err_message,'<null>');
		
		if xact_state() in (-1,1) and @@trancount > 0
			rollback;

		raiserror(@err_text,@err_severity,@err_state);
end catch

select @err_text;