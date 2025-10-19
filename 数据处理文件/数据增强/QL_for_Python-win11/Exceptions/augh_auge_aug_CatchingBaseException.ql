/**
 * @name Exception block catches 'BaseException'
 * @description Identifies exception handlers that catch BaseException without re-raising,
 *              potentially causing improper handling of system exits and keyboard interrupts.
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

// Determine if an exception handler fails to re-raise the caught exception
predicate doesNotReraise(ExceptStmt exceptionHandler) { 
  // Check if control flow from the handler reaches program exit
  exceptionHandler.getAFlowNode().getBasicBlock().reachesExit() 
}

// Detect handlers that catch BaseException or use bare except clauses
predicate catchesBaseException(ExceptStmt exceptionHandler) {
  // Verify explicit BaseException handling
  exceptionHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Identify bare except clauses (catching all exceptions)
  not exists(exceptionHandler.getType())
}

// Primary query: Locate handlers that catch BaseException without re-raising
from ExceptStmt exceptionHandler
where
  catchesBaseException(exceptionHandler) and // Condition: Catches BaseException
  doesNotReraise(exceptionHandler)          // Condition: Doesn't re-raise
select exceptionHandler, "Except block directly handles BaseException." // Output with description