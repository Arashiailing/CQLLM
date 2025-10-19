import python
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.controlflow.ControlFlow

from Method m, Expr e1, Expr e2
where 
  m.hasName("updateSharedResource") and 
  e1.isWriteToVariable(e2.getVariable()) and 
  e2.isReadFromVariable(e1.getVariable()) and 
  not exists(Lock l | l.locksVariable(e1.getVariable()))
select m, "Potential race condition due to concurrent modification of shared resource without synchronization."