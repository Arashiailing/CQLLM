/**
 * @name Except block handles 'BaseException'
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

from ExceptStmt exceptBlock
where
  // Check if exception handler catches BaseException or uses bare except
  (
    exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
    or
    not exists(exceptBlock.getType())
  )
  and
  // Verify exception handler doesn't re-raise the exception
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit()
select exceptBlock, "Except block directly handles BaseException."