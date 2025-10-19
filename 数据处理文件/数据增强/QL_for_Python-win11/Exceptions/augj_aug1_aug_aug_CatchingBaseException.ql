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

// Main query: Identify exception blocks that catch BaseException or all exceptions
// and do not re-raise them, which may mask critical system events
from ExceptStmt exceptBlock
where
  // Condition 1: Check if handler catches BaseException or all exceptions
  (
    // Case A: Explicitly catches BaseException
    exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
    or
    // Case B: Catches all exceptions (no specific type specified)
    not exists(exceptBlock.getType())
  )
  and
  // Condition 2: Verify handler lacks re-raise by checking control flow
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit()
select exceptBlock, "Except block directly handles BaseException."