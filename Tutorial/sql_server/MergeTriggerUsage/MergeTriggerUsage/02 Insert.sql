use [MergeTriggerSamples]
GO

insert [dbo].[MergeTbl](Id,FName)
values (10,'EEEEE');
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
*/
insert [dbo].[MergeTbl](Id,FName)
values (11,'FFFFF'),(12,'FFFFF');
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