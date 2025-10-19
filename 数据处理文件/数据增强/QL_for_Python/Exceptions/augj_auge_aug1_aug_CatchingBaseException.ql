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

from ExceptStmt exceptionHandler
where
  /* Check if handler catches BaseException or uses bare except clause */
  (
    exceptionHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
    or
    not exists(exceptionHandler.getType())
  )
  and
  /* Verify handler doesn't re-raise the caught exception */
  exceptionHandler.getAFlowNode().getBasicBlock().reachesExit()
select exceptionHandler, "Except block directly handles BaseException."