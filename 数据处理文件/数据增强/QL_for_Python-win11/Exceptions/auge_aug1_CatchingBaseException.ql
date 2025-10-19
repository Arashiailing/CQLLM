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

/**
 * Identifies problematic exception handlers that:
 * 1. Catch BaseException or use bare except clauses
 * 2. Fail to re-raise caught exceptions (exit normally)
 */
predicate isProblematicExceptionHandler(ExceptStmt exceptBlock) {
  // Condition 1: Catches BaseException or bare except
  (exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
   or
   not exists(exceptBlock.getType()))
  and
  // Condition 2: Handler exits normally (no re-raise)
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit()
}

from ExceptStmt exceptBlock
where isProblematicExceptionHandler(exceptBlock)
select exceptBlock, "Except block directly handles BaseException."