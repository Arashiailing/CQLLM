/**
 * @name Except block handles 'BaseException'
 * @description Identifies exception handling blocks that catch BaseException or all exceptions
 *              without re-raising them, potentially mis-handling system exits and keyboard interrupts.
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

/**
 * Determines if an exception handler fails to re-raise the caught exception.
 * This is verified by checking if the handler's control flow can reach an exit point
 * without encountering a re-raise operation.
 */
predicate noReraiseInHandler(ExceptStmt handler) { 
  handler.getAFlowNode().getBasicBlock().reachesExit() 
}

/**
 * Checks if an exception handler catches BaseException or all exceptions.
 * Two scenarios are covered:
 * 1. Explicitly catching BaseException via type specification
 * 2. Using a bare except clause (catches all exceptions implicitly)
 */
predicate catchesBaseException(ExceptStmt handler) {
  // Case 1: Explicit BaseException capture
  handler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Case 2: Bare except clause (catch-all)
  not exists(handler.getType())
}

// Main query: Identify problematic exception handlers
from ExceptStmt handler
where
  catchesBaseException(handler) and  // Catches BaseException or all exceptions
  noReraiseInHandler(handler)       // Lacks re-raise mechanism
select handler, "Except block directly handles BaseException."