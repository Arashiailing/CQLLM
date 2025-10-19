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

// Main query: Find exception handlers that catch BaseException or all exceptions
// and do not re-raise them
from ExceptStmt handler
where
  // Check if handler catches BaseException or all exceptions
  (handler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
   or 
   not exists(handler.getType()))
  and
  // Verify handler fails to re-raise the caught exception
  handler.getAFlowNode().getBasicBlock().reachesExit()
select handler, "Except block directly handles BaseException."