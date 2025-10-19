/**
 * @name Except block handles 'BaseException'
 * @description Identifies exception handlers catching BaseException or all exceptions
 *              without re-raising, potentially masking system-exiting events.
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
 * Determines if an exception handler fails to propagate caught exceptions.
 * Verified through control flow analysis to ensure execution can exit
 * the handler without encountering a re-raise statement.
 */
predicate missingReraise(ExceptStmt exceptBlock) { 
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit() 
}

/**
 * Identifies handlers catching BaseException or all exceptions.
 * Covers two scenarios:
 * 1. Explicit BaseException type specification
 * 2. Bare except clauses (implicit catch-all)
 */
predicate handlesBaseException(ExceptStmt exceptBlock) {
  // Explicit BaseException capture
  exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Bare except clause (catch-all)
  not exists(exceptBlock.getType())
}

// Main query: Find handlers catching BaseException without re-raising
from ExceptStmt exceptBlock
where
  handlesBaseException(exceptBlock) and  // Catches BaseException/all exceptions
  missingReraise(exceptBlock)           // Lacks exception re-raising
select exceptBlock, "Except block directly handles BaseException."