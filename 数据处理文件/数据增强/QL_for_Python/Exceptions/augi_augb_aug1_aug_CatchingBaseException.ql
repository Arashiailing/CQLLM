/**
 * @name Exception block catches 'BaseException'
 * @description Identifies exception handlers that catch 'BaseException' without re-raising,
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

// Main query logic: Identify problematic exception handlers
from ExceptStmt exceptionHandler
where
  // Handler catches BaseException or uses bare except clause
  (
    exceptionHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
    or
    not exists(exceptionHandler.getType())
  )
  and
  // Handler's control flow reaches program exit without re-raising
  exceptionHandler.getAFlowNode().getBasicBlock().reachesExit()
select exceptionHandler, "Except block directly handles BaseException."