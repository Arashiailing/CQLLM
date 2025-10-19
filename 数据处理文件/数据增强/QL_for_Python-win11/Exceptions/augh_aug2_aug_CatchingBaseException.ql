/**
 * @name Exception block catches 'BaseException'
 * @description Detects exception handlers that catch 'BaseException' without re-raising,
 *              which can mask system exits and keyboard interrupts.
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
 * Determines if an exception handling block does not re-raise the caught exception.
 * This is verified by analyzing the control flow to check if the basic block
 * containing the exception handler can reach the program exit point.
 */
predicate doesNotReraise(ExceptStmt exceptBlock) { 
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit() 
}

/**
 * Identifies exception handlers that catch BaseException or all exceptions.
 * This includes:
 * 1. Directly catching BaseException
 * 2. Using a bare except clause (which catches all exceptions, including BaseException)
 */
predicate catchesBaseException(ExceptStmt exceptBlock) {
  // Case 1: Exception type is explicitly BaseException
  exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Case 2: No exception type specified (bare except clause)
  not exists(exceptBlock.getType())
}

/**
 * Main query: Identifies improper BaseException handling patterns.
 * 
 * This query detects exception handlers that:
 * 1. Catch BaseException (or all exceptions via bare except)
 * 2. Do not re-raise the exception, potentially masking critical system events
 */
from ExceptStmt exceptBlock
where
  catchesBaseException(exceptBlock) and
  doesNotReraise(exceptBlock)
select exceptBlock, "Except block directly handles BaseException."