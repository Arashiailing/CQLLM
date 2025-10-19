/**
 * @name Exception block catches 'BaseException'
 * @description Detects exception handlers that catch BaseException without re-raising,
 *              which may improperly handle system exits and keyboard interrupts.
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

// Identify exception handlers that catch BaseException (directly or via bare except)
// and fail to re-raise the exception, potentially masking critical system events
from ExceptStmt exceptBlock
where
  // Check for BaseException capture (explicit or implicit)
  (exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
   or
   not exists(exceptBlock.getType()))
  and
  // Verify exception isn't re-raised by analyzing control flow to exit points
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit()
select exceptBlock, "Except block directly handles BaseException."