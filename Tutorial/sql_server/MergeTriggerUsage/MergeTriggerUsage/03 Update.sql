update mt set FName = lower(FName)
from [dbo].[MergeTbl] mt
where Id = 11;
/*
Trigger for update rc=1
Trigger for update i=1
Trigger for update d=1
Trigger after update rc=1
Trigger after update i=1
Trigger after update d=1
Trigger for all rc=1
Trigger for all i=1
Trigger for all d=1
Trigger after all rc=1
Trigger after all i=1
Trigger after all d=1

(1 row(s) affected)
*/

update mt set FName = upper(FName)
from [dbo].[MergeTbl] mt
where Id in  (11,12);
/*
Trigger for update rc=2
Trigger for update i=2
Trigger for update d=2
Trigger after update rc=2
Trigger after update i=2
Trigger after update d=2
Trigger for all rc=2
Trigger for all i=2
Trigger for all d=2
Trigger after all rc=2
Trigger after all i=2
Trigger after all d=2

(2 row(s) affected)

*/