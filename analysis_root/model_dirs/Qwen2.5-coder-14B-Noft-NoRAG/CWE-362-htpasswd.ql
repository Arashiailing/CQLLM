import python

/**
 * This query detects instances of CWE-362: Concurrent Execution using Shared Resource with Improper Synchronization ('Race Condition').
 * It looks for Python code where a shared resource is accessed without proper synchronization.
 */

from FunctionAccess fa, VariableAccess va
where fa.getTarget().getName() = "write"
  and va.getEnclosingCallable() = fa.getEnclosingCallable()
  and va.getVariable().getName() = "htpasswd"
select fa, "This function accesses a shared resource 'htpasswd' without proper synchronization, which may lead to a race condition."