/**
 * @name Exception block catches 'BaseException'
 * @description Capturing 'BaseException' can lead to improper handling of system exits and keyboard interrupts.
 * @kind problem
 * @tags reliability
 *       readability
 *       convention
 *       external/cwe/cwe-396
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/catch-base-exception
 */

import python
import semmle.python.ApiGraphs

// Evaluates whether an exception handler fails to re-raise the caught exception
predicate lacksReraise(ExceptStmt handler) { 
  // Examine control flow to determine if the handler's basic block reaches program exit
  handler.getAFlowNode().getBasicBlock().reachesExit() 
}

// Determines if an exception handler captures BaseException or has no type specified
predicate handlesBaseException(ExceptStmt handler) {
  // Check if exception type is BaseException or if no type is defined
  handler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  not exists(handler.getType())
}

// Main query: Locate exception handlers that catch BaseException without re-raising
from ExceptStmt handler
where
  handlesBaseException(handler) and // Condition: Captures BaseException
  lacksReraise(handler)             // Condition: No re-raise mechanism present
select handler, "Except block directly handles BaseException." // Output selection with description