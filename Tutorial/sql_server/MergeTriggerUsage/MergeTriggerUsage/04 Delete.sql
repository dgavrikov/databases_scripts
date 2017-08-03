delete d
from dbo.MergeTbl d
where Id = 10;
/*
Trigger for deleted rc=1
Trigger for deleted d=1
Trigger after deleted rc=1
Trigger after deleted d=1
Trigger for all rc=1
Trigger for all i=0
Trigger for all d=1
Trigger after all rc=1
Trigger after all i=0
Trigger after all d=1

(1 row(s) affected)

*/

delete d
from dbo.MergeTbl d
where Id in (11,12);
/*
Trigger for deleted rc=2
Trigger for deleted d=2
Trigger after deleted rc=2
Trigger after deleted d=2
Trigger for all rc=2
Trigger for all i=0
Trigger for all d=2
Trigger after all rc=2
Trigger after all i=0
Trigger after all d=2

(2 row(s) affected)
*/