import semmle.code.python.Python

from Call call1, Call call2, Variable var
where call1.getVariable() = var and call2.getVariable() = var
  and call1.getThread()!= call2.getThread()
  and not (call1.getLock() or call2.getLock())
select var, "Potential race condition due to concurrent access without synchronization"