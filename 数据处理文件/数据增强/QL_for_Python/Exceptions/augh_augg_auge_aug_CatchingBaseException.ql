/**
 * @name Exception block catches 'BaseException'
 * @description Detects exception handling blocks that catch BaseException or use bare except clauses
 *              without re-raising the exception. This practice can hide system-exiting events such as
 *              SystemExit or KeyboardInterrupt, which may result in improper program termination.
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

// Identify handlers that catch BaseException or use bare except clauses
predicate handlesBaseException(ExceptStmt exceptBlock) {
  // Check for explicit BaseException handling
  exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Check for bare except clauses (catches all exceptions including BaseException)
  not exists(exceptBlock.getType())
}

// Determine if an exception handler fails to re-raise the caught exception
predicate failsToReraiseException(ExceptStmt exceptBlock) { 
  // Verify that control flow from the handler reaches program exit
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit() 
}

// Main query: Find exception handlers that catch BaseException without re-raising
from ExceptStmt exceptBlock
where
  handlesBaseException(exceptBlock) and // Condition: Catches BaseException or uses bare except
  failsToReraiseException(exceptBlock) // Condition: Does not re-raise the exception
select exceptBlock, "Except block directly handles BaseException without re-raising." // Output with description