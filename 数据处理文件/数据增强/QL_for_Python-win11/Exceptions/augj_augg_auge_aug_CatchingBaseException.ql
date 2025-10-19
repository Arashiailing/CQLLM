/**
 * @name Exception block catches 'BaseException'
 * @description Detects exception handling blocks that catch BaseException or utilize bare except clauses
 *              without re-raising the exception. This pattern can hide system-exiting events such as
 *              SystemExit or KeyboardInterrupt, potentially causing improper program termination.
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

// Predicate to identify handlers that catch BaseException or use bare except clauses
predicate catchesBaseException(ExceptStmt exceptBlock) {
  // Check for explicit BaseException handling in the except clause
  exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Check for bare except clauses (catches all exceptions including BaseException)
  not exists(exceptBlock.getType())
}

// Predicate to determine if an exception block does not re-raise the caught exception
predicate lacksReraise(ExceptStmt exceptBlock) { 
  // Verify that control flow from the exception block reaches program exit
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit() 
}

// Main query: Find exception handlers that catch BaseException without re-raising
from ExceptStmt exceptBlock
where
  catchesBaseException(exceptBlock) and
  lacksReraise(exceptBlock)
select exceptBlock, "Except block directly handles BaseException without re-raising."