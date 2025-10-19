/**
 * @name Except block handles 'BaseException'
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

// Identify exception handlers that catch BaseException or all exceptions
// without re-raising them, which may mask critical system signals
from ExceptStmt exceptionHandler
where
  // Check if handler catches BaseException or all exceptions (bare except)
  (
    exceptionHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
    or
    not exists(exceptionHandler.getType())
  )
  and
  // Verify handler lacks re-raise by checking if its basic block reaches exit
  exceptionHandler.getAFlowNode().getBasicBlock().reachesExit()
select exceptionHandler, "Except block directly handles BaseException."