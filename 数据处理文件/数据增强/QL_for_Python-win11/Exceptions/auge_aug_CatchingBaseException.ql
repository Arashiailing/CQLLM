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

// Identify exception handlers that don't re-raise exceptions
predicate lacksReraise(ExceptStmt handler) { 
  // Verify control flow reaches program exit from the handler
  handler.getAFlowNode().getBasicBlock().reachesExit() 
}

// Identify handlers catching BaseException or unspecified exceptions
predicate handlesBaseException(ExceptStmt handler) {
  // Check for explicit BaseException handling
  handler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Check for bare except clauses (catches all exceptions)
  not exists(handler.getType())
}

// Main query: Find handlers catching BaseException without re-raising
from ExceptStmt handler
where
  handlesBaseException(handler) and // Condition: Catches BaseException
  lacksReraise(handler)            // Condition: Doesn't re-raise
select handler, "Except block directly handles BaseException." // Output with description