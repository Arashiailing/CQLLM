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
predicate catchesGenericBaseException(ExceptStmt exceptionBlock) {
  exceptionBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  not exists(exceptionBlock.getType())
}

// Determines if an exception handler fails to re-raise caught exceptions
predicate handlerExitsNormally(ExceptStmt exceptionBlock) { 
  exceptionBlock.getAFlowNode().getBasicBlock().reachesExit() 
}

// Combines detection logic for problematic exception handling patterns
predicate isProblematicExceptionHandler(ExceptStmt exceptionBlock) {
  catchesGenericBaseException(exceptionBlock) and 
  handlerExitsNormally(exceptionBlock)
}

from ExceptStmt exceptionBlock
where isProblematicExceptionHandler(exceptionBlock)
select exceptionBlock, "Except block directly handles BaseException."