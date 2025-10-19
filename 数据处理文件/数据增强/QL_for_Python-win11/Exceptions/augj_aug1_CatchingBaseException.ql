/**
 * @name Except block handles 'BaseException'
 * @description Detects exception handlers that catch BaseException or use bare except clauses
 *              without re-raising exceptions, which may mis-handle system exits and interrupts.
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

// Checks if an exception handler completes without re-raising caught exceptions
predicate exitsWithoutReraising(ExceptStmt exceptionHandler) { 
  exceptionHandler.getAFlowNode().getBasicBlock().reachesExit() 
}

// Identifies handlers catching BaseException or using bare except clauses
predicate catchesBaseExceptionOrBareExcept(ExceptStmt exceptionHandler) {
  exceptionHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  not exists(exceptionHandler.getType())
}

// Combines conditions to detect problematic exception handling patterns
predicate hasProblematicExceptionHandler(ExceptStmt exceptionHandler) {
  catchesBaseExceptionOrBareExcept(exceptionHandler) and 
  exitsWithoutReraising(exceptionHandler)
}

from ExceptStmt exceptionHandler
where hasProblematicExceptionHandler(exceptionHandler)
select exceptionHandler, "Except block directly handles BaseException."