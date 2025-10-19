/**
 * @name Exception block catches 'BaseException'
 * @description Capturing 'BaseException' can lead to improper handling of system exits and keyboard interrupts.
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
 * Determines if an exception handler block fails to re-raise the caught exception.
 * This is verified by analyzing control flow to check if the basic block
 * containing the exception handler can reach a program exit point.
 */
predicate failsToReraise(ExceptStmt handler) { 
  handler.getAFlowNode().getBasicBlock().reachesExit() 
}

/**
 * Identifies exception handlers that capture BaseException or all exceptions.
 * This includes handlers that explicitly specify BaseException as the caught type
 * and those that omit an exception type entirely (bare except clauses).
 */
predicate handlesBaseException(ExceptStmt handler) {
  // Check if the exception type is BaseException
  handler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Or if no exception type is specified (bare except clause)
  not exists(handler.getType())
}

/**
 * Main query to detect problematic BaseException handling patterns.
 * Locates exception handlers that:
 * 1. Capture BaseException (or all exceptions)
 * 2. Do not re-raise the caught exception
 */
from ExceptStmt handler
where
  handlesBaseException(handler) and
  failsToReraise(handler)
select handler, "Except block directly handles BaseException."