import python

/**
 * @name CWE-476: NULL Pointer Dereference
 * @description The product dereferences a pointer that it expects to be valid but is NULL.
 */
from Assign assign, Call call, Access access
where (assign.getVariable() = call.getTarget() or assign.getVariable() = access.getTarget())
  and assign.getValue().isNone()
  and call.getMethodName()!= "get"  // Exclude common safe methods like.get()
  and not exists (call.getLocation().getFile(), call.getLocation().getLine(), 
                 (if (call.getLocation().getFile() == access.getLocation().getFile()) 
                  then (call.getLocation().getLine() < access.getLocation().getLine()) 
                  else true))
select call, "Potential NULL pointer dereference detected"