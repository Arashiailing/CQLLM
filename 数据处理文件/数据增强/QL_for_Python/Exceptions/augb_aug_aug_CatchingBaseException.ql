/**
 * @name Exception handler catches BaseException without re-raising
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
 * This is verified by checking if the handler's basic block can reach an exit point.
 */
predicate noReraise(ExceptStmt exceptHandler) { 
  exceptHandler.getAFlowNode().getBasicBlock().reachesExit() 
}

/**
 * Checks if an exception handler catches BaseException or all exceptions.
 * Two scenarios are considered:
 * 1. Explicitly catching BaseException
 * 2. Using a bare except clause (catching all exceptions)
 */
predicate catchesBaseException(ExceptStmt exceptHandler) {
  // Explicitly catches BaseException
  exceptHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Bare except clause catches all exceptions
  not exists(exceptHandler.getType())
}

// Main query: Find exception handlers that catch BaseException or all exceptions
// and do not re-raise them
from ExceptStmt exceptHandler
where
  catchesBaseException(exceptHandler) and  // Catches BaseException or all exceptions
  noReraise(exceptHandler)                // Does not re-raise the exception
select exceptHandler, "Except block directly handles BaseException."