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

/**
 * Verifies if an exception handler fails to re-raise the caught exception.
 * This predicate confirms that control flow from the handler reaches program exit
 * without re-raising the exception.
 */
predicate failsToReraise(ExceptStmt exceptionHandler) { 
  // Check that handler's control flow reaches exit without re-raising
  exceptionHandler.getAFlowNode().getBasicBlock().reachesExit() 
}

/**
 * Identifies exception handlers catching BaseException or using bare except.
 * This predicate detects handlers that catch the base exception class or all exceptions.
 */
predicate catchesBaseException(ExceptStmt exceptionHandler) {
  // Handler explicitly catches BaseException type
  exceptionHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Handler uses bare except clause (catches all exceptions including BaseException)
  not exists(exceptionHandler.getType())
}

// Identify problematic exception handlers
from ExceptStmt exceptionHandler
where
  // Handler catches BaseException or uses bare except
  catchesBaseException(exceptionHandler) and
  // Handler does not re-raise the caught exception
  failsToReraise(exceptionHandler)
select exceptionHandler, "Except block directly handles BaseException."