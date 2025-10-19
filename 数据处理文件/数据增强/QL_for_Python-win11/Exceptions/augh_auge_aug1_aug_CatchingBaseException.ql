/**
 * @name Exception block catches 'BaseException'
 * @description Detects exception handlers that catch 'BaseException' without re-raising,
 *              which may interfere with system exits and keyboard interrupts.
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
  /* Check if handler catches BaseException or uses bare except */
  (
    exceptionHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
    or
    not exists(exceptionHandler.getType())
  )
  and
  /* Verify handler doesn't re-raise the exception */
  exceptionHandler.getAFlowNode().getBasicBlock().reachesExit()
select exceptionHandler, "Except block directly handles BaseException."