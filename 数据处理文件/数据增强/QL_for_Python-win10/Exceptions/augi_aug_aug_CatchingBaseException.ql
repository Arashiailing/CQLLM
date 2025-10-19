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
 * This is confirmed by verifying that the handler's control flow can reach
 * an exit point without re-raising the exception.
 */
predicate failsToReraise(ExceptStmt exceptionHandler) { 
  exceptionHandler.getAFlowNode().getBasicBlock().reachesExit() 
}

/**
 * Checks if an exception handler catches BaseException or all exceptions.
 * Covers two scenarios:
 * 1. Explicitly catching BaseException
 * 2. Using a bare except clause (catching all exceptions)
 */
predicate catchesBaseException(ExceptStmt exceptionHandler) {
  // Case 1: Explicit BaseException handling
  exceptionHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Case 2: Bare except clause catches everything
  not exists(exceptionHandler.getType())
}

// Main query: Identify exception handlers that catch BaseException/all exceptions
// and fail to re-raise them
from ExceptStmt exceptionHandler
where
  catchesBaseException(exceptionHandler) and  // Catches BaseException or all exceptions
  failsToReraise(exceptionHandler)            // Does not re-raise the exception
select exceptionHandler, "Except block directly handles BaseException."