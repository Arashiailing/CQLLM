/**
 * @name CWE-362: Concurrent Execution using Shared Resource with Improper Synchronization
 * @description Detects race conditions caused by improper synchronization of shared resources.
 */
import python
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.controlflow.ControlFlow

// Define shared resources as global variables or class members
predicate isSharedResource(Variable var) {
  var.isGlobal() or var.isClassMember()
}

// Find potential race conditions between multiple threads modifying shared resources
from Variable sharedVar, Call siteCall, Call threadCall
where
  isSharedResource(sharedVar)
  and siteCall.getSymbol().getName() = "modify"  // Replace with actual modification operation
  and threadCall.getSymbol().getName() = "start"  // Replace with actual thread start operation
  and threadCall.getExpression().getSymbol().getName() = "Thread"
  and siteCall.getFunction().getQualifiedName() = threadCall.getFunction().getQualifiedName()
  and siteCall.getLocation().getFile() = threadCall.getLocation().getFile()
  and siteCall.getLocation().getLine() > threadCall.getLocation().getLine()
select sharedVar, "Potential race condition: Shared resource $var$ accessed without proper synchronization.", siteCall