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
 * Identifies exception handlers catching BaseException or using bare except.
 * This predicate detects handlers that catch the base exception class or all exceptions.
 */
predicate catchesBaseException(ExceptStmt exceptStmt) {
  // Handler explicitly catches BaseException type
  exceptStmt.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Handler uses bare except clause (catches all exceptions including BaseException)
  not exists(exceptStmt.getType())
}

/**
 * Verifies if an exception handler fails to re-raise the caught exception.
 * This predicate confirms that control flow from the handler reaches program exit
 * without re-raising the exception.
 */
predicate failsToReraise(ExceptStmt exceptStmt) { 
  // Check that handler's control flow reaches exit without re-raising
  exceptStmt.getAFlowNode().getBasicBlock().reachesExit() 
}

// Identify problematic exception handlers
from ExceptStmt exceptStmt
where
  // The exception handler catches BaseException or uses a bare except clause
  catchesBaseException(exceptStmt) and
  // and does not re-raise the caught exception
  failsToReraise(exceptStmt)
select exceptStmt, "Except block directly handles BaseException."