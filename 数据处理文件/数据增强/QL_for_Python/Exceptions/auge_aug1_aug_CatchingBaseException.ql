/**
 * @name Exception block catches 'BaseException'
 * @description Identifies exception handlers that capture 'BaseException' without re-raising,
 *              potentially interfering with system exits and keyboard interrupts.
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
  /* Condition 1: Handler catches BaseException or uses bare except */
  (
    exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
    or
    not exists(exceptBlock.getType())
  )
  and
  /* Condition 2: Handler does not re-raise the exception */
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit()
select exceptBlock, "Except block directly handles BaseException."