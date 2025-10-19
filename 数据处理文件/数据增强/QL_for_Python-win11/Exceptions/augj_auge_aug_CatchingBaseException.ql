/**
 * @name Exception block catches 'BaseException'
 * @description Identifies exception handlers that catch BaseException without re-raising,
 *              potentially masking system-critical exceptions like keyboard interrupts or exits.
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

// Determine if an exception handler fails to re-raise the caught exception
predicate doesNotReraiseException(ExceptStmt exceptionHandler) {
  // Check if control flow from the handler can reach program exit
  // This indicates the exception is not being re-raised
  exceptionHandler.getAFlowNode().getBasicBlock().reachesExit()
}

// Identify exception handlers that catch BaseException or use bare except clauses
predicate catchesBaseException(ExceptStmt exceptionHandler) {
  // Case 1: Explicitly catches BaseException
  exceptionHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Case 2: Bare except clause (catches all exceptions including BaseException)
  not exists(exceptionHandler.getType())
}

// Main query logic: Find problematic exception handlers
from ExceptStmt exceptionHandler
where
  catchesBaseException(exceptionHandler) and  // Handler catches BaseException or all exceptions
  doesNotReraiseException(exceptionHandler)   // Handler doesn't re-raise the exception
select exceptionHandler, "Except block directly handles BaseException."  // Result with description