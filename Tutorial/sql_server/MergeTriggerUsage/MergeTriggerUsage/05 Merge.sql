;merge dbo.MergeTbl trg
using (
select 3 as Id,'CCC' FName
)src
	on trg.Id = src.Id
when not matched then 
insert values (Id,FName);
/*
Trigger for insert rc=1
Trigger for insert i=1
Trigger after insert rc=1
Trigger after insert i=1
Trigger for all rc=1
Trigger for all i=1
Trigger for all d=0
Trigger after all rc=1
Trigger after all i=1
Trigger after all d=0

(1 row(s) affected)

*/

;merge dbo.MergeTbl trg
using (
select 3 as Id,'CCC' FName
)src
	on trg.Id = src.Id
when matched then update set FName = src.FName
when not matched then 
insert values (Id,FName);
/*
Trigger for insert rc=1
Trigger for insert i=0
Trigger after insert rc=1
Trigger after insert i=0
Trigger for all rc=1
Trigger for all i=0
Trigger for all d=0
Trigger after all rc=1
Trigger after all i=0
Trigger after all d=0
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

;merge dbo.MergeTbl trg
using (
select 3 as Id,'CCC' FName
union all 
select 4 as Id,'DDD' FName
union all 
select 12 as Id,'FFF' FName

)src
	on trg.Id = src.Id
when not matched then 
insert values (Id,FName);
/*
Trigger for insert rc=2
Trigger for insert i=2
Trigger after insert rc=2
Trigger after insert i=2
Trigger for all rc=2
Trigger for all i=2
Trigger for all d=0
Trigger after all rc=2
Trigger after all i=2
Trigger after all d=0

(2 row(s) affected)
*/

;merge dbo.MergeTbl trg
using (
select 21 as Id,'CCC' FName
union all 
select 4 as Id,'DDD' FName
union all 
select 12 as Id,'FFF' FName

)src
	on trg.Id = src.Id
when matched then update set FName = src.FName
when not matched then 
insert values (Id,FName);
/*
Trigger for insert rc=3
Trigger for insert i=1
Trigger after insert rc=3
Trigger after insert i=1
Trigger for all rc=3
Trigger for all i=1
Trigger for all d=0
Trigger after all rc=3
Trigger after all i=1
Trigger after all d=0
Trigger for update rc=3
Trigger for update i=2
Trigger for update d=2
Trigger after update rc=3
Trigger after update i=2
Trigger after update d=2
Trigger for all rc=3
Trigger for all i=2
Trigger for all d=2
Trigger after all rc=3
Trigger after all i=2
Trigger after all d=2

(3 row(s) affected)
*/