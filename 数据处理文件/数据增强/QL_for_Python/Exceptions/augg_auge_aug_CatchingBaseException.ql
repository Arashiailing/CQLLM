/**
 * @name Exception block catches 'BaseException'
 * @description Identifies exception handling blocks that catch BaseException or use bare except clauses
 *              without re-raising the exception. This pattern can mask system-exiting events like
 *              SystemExit or KeyboardInterrupt, potentially leading to improper program termination.
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

// Determine if an exception handler does not re-raise the caught exception
predicate doesNotReraiseException(ExceptStmt exceptionHandler) { 
  // Check if control flow from the handler reaches program exit
  exceptionHandler.getAFlowNode().getBasicBlock().reachesExit() 
}

// Identify handlers that catch BaseException or use bare except clauses
predicate catchesBaseException(ExceptStmt exceptionHandler) {
  // Check for explicit BaseException handling
  exceptionHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Check for bare except clauses (catches all exceptions including BaseException)
  not exists(exceptionHandler.getType())
}

// Main query: Find exception handlers that catch BaseException without re-raising
from ExceptStmt exceptionHandler
where
  catchesBaseException(exceptionHandler) and // Condition: Catches BaseException or uses bare except
  doesNotReraiseException(exceptionHandler) // Condition: Does not re-raise the exception
select exceptionHandler, "Except block directly handles BaseException without re-raising." // Output with description