/**
 * @name Exception block catches 'BaseException'
 * @description Detects exception handlers that catch 'BaseException' without re-raising,
 *              which may improperly handle system exits and keyboard interrupts.
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

// Determines if an exception handler does not re-raise the caught exception
predicate isNotReraising(ExceptStmt handler) { 
  // Verify the handler's control flow reaches program exit without re-raising
  handler.getAFlowNode().getBasicBlock().reachesExit() 
}

// Checks if an exception handler catches BaseException or uses bare except
predicate capturesBaseException(ExceptStmt handler) {
  // Handler explicitly catches BaseException type
  handler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Handler uses bare except clause (catches all exceptions including BaseException)
  not exists(handler.getType())
}

// Main query logic: Find handlers catching BaseException without re-raising
from ExceptStmt handler
where
  /* Condition 1: Handler catches BaseException or uses bare except */
  capturesBaseException(handler) and
  /* Condition 2: Handler does not re-raise the exception */
  isNotReraising(handler)
select handler, "Except block directly handles BaseException."