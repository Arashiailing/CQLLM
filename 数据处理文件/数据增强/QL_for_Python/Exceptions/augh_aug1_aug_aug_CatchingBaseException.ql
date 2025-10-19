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

// Identify exception handling blocks that catch BaseException or all exceptions
// without re-raising them
from ExceptStmt exceptBlock
where
  // Check if handler catches BaseException or all exceptions
  (
    exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
    or
    not exists(exceptBlock.getType())
  )
  and
  // Verify handler lacks re-raise by checking if its basic block reaches exit
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit()
select exceptBlock, "Except block directly handles BaseException."