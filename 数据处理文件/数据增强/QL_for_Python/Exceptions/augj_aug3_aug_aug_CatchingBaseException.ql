/**
 * @name Except block handles 'BaseException'
 * @description Detects exception handlers that catch BaseException or use bare except clauses
 *              without re-raising, which may improperly handle system-exiting exceptions.
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
 * Identifies exception handlers that either explicitly catch BaseException
 * or use bare except clauses, and do not re-raise the caught exception.
 */
predicate problematicExceptionHandler(ExceptStmt exceptionBlock) {
  // Check if the handler catches BaseException or all exceptions
  (exceptionBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  not exists(exceptionBlock.getType())) and
  // Verify the handler doesn't re-raise the exception
  exceptionBlock.getAFlowNode().getBasicBlock().reachesExit()
}

// Main query: Find exception blocks that improperly handle BaseException
from ExceptStmt exceptionBlock
where problematicExceptionHandler(exceptionBlock)
select exceptionBlock, "Except block directly handles BaseException."