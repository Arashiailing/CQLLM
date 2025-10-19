/**
 * @name Exception block catches 'BaseException'
 * @description Detects exception handlers that catch BaseException without re-raising,
 *              which may mask system-critical signals like KeyboardInterrupt or SystemExit.
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
 * Identifies exception handlers that catch BaseException or use bare except clauses.
 * This includes handlers explicitly catching BaseException and those without
 * specified exception types (bare except).
 */
predicate catchesBaseException(ExceptStmt exceptionHandler) {
  // Check for explicit BaseException handling
  exceptionHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Check for bare except clause (no exception type specified)
  not exists(exceptionHandler.getType())
}

/**
 * Determines if an exception handler fails to propagate the caught exception.
 * This is detected by analyzing control flow to see if the handler's basic block
 * can reach program exit without re-raising the exception.
 */
predicate doesNotReraise(ExceptStmt exceptionHandler) { 
  exceptionHandler.getAFlowNode().getBasicBlock().reachesExit() 
}

/**
 * Main query logic: Finds exception handlers that:
 * 1. Catch BaseException (or all exceptions via bare except)
 * 2. Do not re-raise the caught exception
 */
from ExceptStmt exceptionHandler
where
  catchesBaseException(exceptionHandler) and
  doesNotReraise(exceptionHandler)
select exceptionHandler, "Except block catches BaseException without re-raising."