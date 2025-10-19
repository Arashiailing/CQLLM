/**
 * @name Exception block catches 'BaseException'
 * @description Identifies exception handlers that catch BaseException without re-raising,
 *              potentially masking system exits and keyboard interrupts.
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

// Main query: Detect problematic exception handlers
from ExceptStmt exceptStmt
where
  // Condition 1: Handler catches BaseException or has no type specified
  (exceptStmt.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
   or
   not exists(exceptStmt.getType()))
  and
  // Condition 2: Handler lacks re-raise mechanism (reaches program exit)
  exceptStmt.getAFlowNode().getBasicBlock().reachesExit()
select exceptStmt, "Except block directly handles BaseException."