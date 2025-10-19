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
 * Determines if an exception handler catches BaseException or all exceptions
 * without re-raising the caught exception. This combines two checks:
 * 1. Whether the handler catches BaseException explicitly or via bare except
 * 2. Whether the handler allows control flow to exit without re-raising
 */
predicate isProblematicExceptionHandler(ExceptStmt exceptHandler) {
  // Check if handler catches BaseException or all exceptions
  (exceptHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
   or
   not exists(exceptHandler.getType()))
  and
  // Check if handler fails to re-raise the exception
  exceptHandler.getAFlowNode().getBasicBlock().reachesExit()
}

// Main query: Identify problematic exception handlers
from ExceptStmt exceptHandler
where isProblematicExceptionHandler(exceptHandler)
select exceptHandler, "Except block directly handles BaseException."