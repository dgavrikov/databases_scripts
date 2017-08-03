select
rdc.*, -- информация о строковых полях 
plc.*, -- где расположены данные, но в отдельных колонках
sys.fn_PhysLocFormatter(%%physloc%%) as PhysLocation, -- где расположены данные
%%lockres%% as [lockres], -- идентификатор заблокированного ресурса
p.*
from dbo.Objects p
cross apply sys.fn_RowDumpCracker(%%rowdump%%) rdc
cross apply sys.fn_PhysLocCracker(%%physloc%%) plc 