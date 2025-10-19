/**
 * @name Exception block catches 'BaseException'
 * @description Identifies exception handlers catching 'BaseException' without re-raising,
 *              which can interfere with system exits and keyboard interrupts.
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
  /* Identify handlers catching BaseException or using bare except */
  (
    exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
    or
    not exists(exceptBlock.getType())
  )
  and
  /* Confirm handler doesn't re-raise the exception */
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit()
select exceptBlock, "Except block directly handles BaseException."