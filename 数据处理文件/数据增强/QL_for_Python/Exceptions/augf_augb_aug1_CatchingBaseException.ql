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

// Identifies exception handlers that catch BaseException or use bare except clauses
predicate catchesGenericBaseException(ExceptStmt exceptStmt) {
  exceptStmt.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  not exists(exceptStmt.getType())
}

// Determines if an exception handler fails to re-raise caught exceptions
predicate handlerExitsNormally(ExceptStmt exceptStmt) { 
  exceptStmt.getAFlowNode().getBasicBlock().reachesExit() 
}

// Combines detection logic for problematic exception handling patterns
predicate isProblematicExceptionHandler(ExceptStmt exceptStmt) {
  catchesGenericBaseException(exceptStmt) and 
  handlerExitsNormally(exceptStmt)
}

from ExceptStmt exceptStmt
where isProblematicExceptionHandler(exceptStmt)
select exceptStmt, "Except block directly handles BaseException."