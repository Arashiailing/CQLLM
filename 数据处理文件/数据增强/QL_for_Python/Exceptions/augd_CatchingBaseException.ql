/**
 * @name Except block handles 'BaseException'
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

// Determines if an exception handler suppresses exceptions without re-raising
predicate suppressesException(ExceptStmt handler) {
  handler.getAFlowNode().getBasicBlock().reachesExit()
}

// Identifies exception handlers that catch BaseException or use bare except clauses
predicate handlesBaseException(ExceptStmt handler) {
  // Explicit BaseException handling
  handler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Bare except clause (catches all exceptions including BaseException)
  not exists(handler.getType())
}

// Main query: Find problematic exception handlers
from ExceptStmt handler
where
  handlesBaseException(handler) and  // Catches BaseException or all exceptions
  suppressesException(handler)      // Suppresses exceptions without re-raising
select handler, "Except block directly handles BaseException."