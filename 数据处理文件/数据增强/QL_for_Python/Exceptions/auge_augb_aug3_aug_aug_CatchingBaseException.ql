/**
 * @name Except block handles 'BaseException'
 * @description Detects exception handlers that catch BaseException or all exceptions
 *              without re-raising them, which can lead to improper handling of
 *              system-exiting events like keyboard interrupts.
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
 * Determines if an exception handler fails to re-raise caught exceptions.
 * This is verified by analyzing the control flow to check if execution
 * can reach the exit point without encountering a re-raise statement.
 */
predicate missingReraise(ExceptStmt exceptHandler) { 
  exceptHandler.getAFlowNode().getBasicBlock().reachesExit() 
}

/**
 * Identifies exception handlers that catch BaseException or all exceptions.
 * This predicate covers two scenarios:
 * 1. Handlers that explicitly specify BaseException as the caught exception type
 * 2. Bare except clauses that implicitly catch all exceptions
 */
predicate handlesBaseException(ExceptStmt exceptHandler) {
  // Case 1: Explicit BaseException capture
  exceptHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Case 2: Bare except clause (catch-all)
  not exists(exceptHandler.getType())
}

// Main query: Locate exception handlers that catch BaseException without re-raising
from ExceptStmt exceptHandler
where
  handlesBaseException(exceptHandler) and  // Catches BaseException or all exceptions
  missingReraise(exceptHandler)           // Does not re-raise the caught exception
select exceptHandler, "Except block directly handles BaseException."