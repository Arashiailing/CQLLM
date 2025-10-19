/**
 * @name Exception handler catches BaseException without re-raising
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

// Main query: Find exception handlers catching BaseException or all exceptions
// without re-raising the caught exception
from ExceptStmt exceptBlock
where
  // Check if exception handler catches BaseException type
  (exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
   or 
   // Or catches all exceptions (no explicit type specified)
   not exists(exceptBlock.getType()))
  and
  // Verify the exception handler doesn't re-raise the caught exception
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit()
select exceptBlock, "Except block directly handles BaseException."