/**
 * @name Except block handles 'BaseException'
 * @description Handling 'BaseException' means that system exits and keyboard interrupts may be mis-handled.
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

// Determines if an exception handler fails to re-raise caught exceptions
predicate handlerExitsNormally(ExceptStmt handler) { 
  handler.getAFlowNode().getBasicBlock().reachesExit() 
}

// Identifies exception handlers that catch BaseException or use bare except clauses
predicate catchesGenericBaseException(ExceptStmt handler) {
  handler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  not exists(handler.getType())
}

// Combines detection logic for problematic exception handling
predicate isProblematicExceptionHandler(ExceptStmt handler) {
  catchesGenericBaseException(handler) and 
  handlerExitsNormally(handler)
}

from ExceptStmt handler
where isProblematicExceptionHandler(handler)
select handler, "Except block directly handles BaseException."