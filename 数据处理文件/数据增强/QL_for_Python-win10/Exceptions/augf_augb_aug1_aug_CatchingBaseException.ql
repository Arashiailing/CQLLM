/**
 * @name Exception block catches 'BaseException'
 * @description Identifies exception handlers that catch 'BaseException' without re-raising,
 *              potentially mishandling system exits and keyboard interrupts.
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

// Main query logic: Identify problematic exception handlers
from ExceptStmt handlerBlock
where
  // Check if handler catches BaseException or uses bare except clause
  (handlerBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr() or
   not exists(handlerBlock.getType())) and
  // Verify handler doesn't re-raise exception before program exit
  handlerBlock.getAFlowNode().getBasicBlock().reachesExit()
select handlerBlock, "Except block directly handles BaseException."