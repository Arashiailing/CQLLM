/**
 * @name Exception handler catches BaseException without re-raising
 * @description Detects exception handlers that intercept BaseException or all exceptions
 *              without re-raising, which may improperly handle system exits and interrupts.
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
 * Verifies if an exception handler does not re-raise the caught exception.
 * This is determined by checking if the handler's basic block can reach an exit point.
 */
predicate lacksReraise(ExceptStmt handler) { 
  handler.getAFlowNode()
        .getBasicBlock()
        .reachesExit() 
}

/**
 * Determines if an exception handler catches BaseException or all exceptions.
 * Two cases are considered:
 * 1. Explicitly catching BaseException
 * 2. Using a bare except clause (catching all exceptions)
 */
predicate interceptsBaseException(ExceptStmt handler) {
  (
    // Explicitly catches BaseException
    handler.getType() = API::builtin("BaseException")
                              .getAValueReachableFromSource()
                              .asExpr()
  )
  or
  (
    // Bare except clause catches all exceptions
    not exists(handler.getType())
  )
}

// Main query: Identify exception handlers that catch BaseException or all exceptions
// and fail to re-raise them
from ExceptStmt exceptHandler
where
  interceptsBaseException(exceptHandler) and  // Catches BaseException or all exceptions
  lacksReraise(exceptHandler)                // Does not re-raise the exception
select exceptHandler, "Except block directly handles BaseException."