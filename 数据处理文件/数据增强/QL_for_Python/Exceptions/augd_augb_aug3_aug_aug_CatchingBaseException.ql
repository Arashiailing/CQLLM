/**
 * @name Except block handles 'BaseException'
 * @description Identifies exception handlers catching BaseException or all exceptions
 *              without re-raising, potentially mis-handling system exits and interrupts.
 *              This analysis verifies two conditions:
 *              1. Exception handler catches BaseException explicitly or uses bare except
 *              2. Control flow reaches exit without encountering re-raise statement
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

// Main query: Identify problematic exception handlers
from ExceptStmt exceptHandler
where
  // Condition 1: Catches BaseException or all exceptions
  (
    exceptHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
    or
    not exists(exceptHandler.getType())  // Bare except clause
  )
  and
  // Condition 2: Lacks re-raise mechanism
  exceptHandler.getAFlowNode().getBasicBlock().reachesExit()
select exceptHandler, "Except block directly handles BaseException."