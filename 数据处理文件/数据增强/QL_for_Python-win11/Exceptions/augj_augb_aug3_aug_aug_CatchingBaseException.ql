/**
 * @name Except block handles 'BaseException'
 * @description Identifies exception handlers catching BaseException or all exceptions
 *              without re-raising, potentially mis-handling system exits and interrupts.
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

/**
 * Identifies problematic except blocks that catch BaseException or all exceptions
 * without re-raising, which may prevent proper system exit handling.
 */
predicate isProblematicExceptBlock(ExceptStmt exceptStmt) {
  // Checks if the except block catches BaseException or all exceptions
  (exceptStmt.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
   or
   not exists(exceptStmt.getType()))
  and
  // Verifies the block lacks re-raise mechanism by checking control flow
  exceptStmt.getAFlowNode().getBasicBlock().reachesExit()
}

// Main query: Identify problematic exception handlers
from ExceptStmt exceptStmt
where 
  isProblematicExceptBlock(exceptStmt)
select exceptStmt, "Except block directly handles BaseException."