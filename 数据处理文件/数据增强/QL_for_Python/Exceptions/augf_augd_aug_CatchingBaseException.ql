/**
 * @name Exception block catches 'BaseException'
 * @description Identifies exception handlers that catch BaseException without re-raising,
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

// Identify exception handlers catching BaseException without re-raising
from ExceptStmt exceptBlock
where
  // Condition 1: Handler catches BaseException or unspecified exception type
  (
    exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
    or
    not exists(exceptBlock.getType())
  )
  and
  // Condition 2: Handler doesn't re-raise the exception
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit()
select exceptBlock, "Except block directly handles BaseException."