/**
 * @name Except block handles 'BaseException'
 * @description Identifies except blocks that catch BaseException or all exceptions
 *              without re-raising them, potentially mis-handling system exits and keyboard interrupts.
 *              The query detects except blocks that either explicitly catch BaseException or use bare except clauses,
 *              and verifies the except block reaches an exit point without re-raising the exception.
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

from ExceptStmt exceptBlock
where
  // Check if handler catches BaseException explicitly or uses bare except
  (exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
   or
   not exists(exceptBlock.getType()))
  and
  // Verify handler doesn't re-raise exception by checking if it reaches exit
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit()
select exceptBlock, "Except block directly handles BaseException."