/**
 * @name Except block handles 'BaseException'
 * @description Detects except blocks that catch BaseException or use bare except clauses without re-raising exceptions.
 *              Such handling may cause mis-handling of system exits and keyboard interrupts.
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
predicate catchesGenericBaseException(ExceptStmt exceptBlock) {
  exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  not exists(exceptBlock.getType())
}

// Determines if an exception handler fails to re-raise caught exceptions
predicate handlerExitsNormally(ExceptStmt exceptBlock) { 
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit() 
}

// Combines detection logic for problematic exception handling patterns
predicate isProblematicExceptionHandler(ExceptStmt exceptBlock) {
  catchesGenericBaseException(exceptBlock) and 
  handlerExitsNormally(exceptBlock)
}

from ExceptStmt problematicExceptBlock
where isProblematicExceptionHandler(problematicExceptBlock)
select problematicExceptBlock, "Except block directly handles BaseException."