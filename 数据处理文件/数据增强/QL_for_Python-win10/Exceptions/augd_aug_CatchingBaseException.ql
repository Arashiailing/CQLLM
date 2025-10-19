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

// Main query: Identify exception handlers catching BaseException without re-raising
from ExceptStmt exceptionHandler
where
  // Check if exception handler catches BaseException or unspecified exception type
  (
    exceptionHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
    or
    not exists(exceptionHandler.getType())
  )
  and
  // Verify exception handler doesn't re-raise the exception
  exceptionHandler.getAFlowNode().getBasicBlock().reachesExit()
select exceptionHandler, "Except block directly handles BaseException."