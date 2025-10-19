/**
 * @name Exception handler catches BaseException without re-raising
 * @description Identifies exception handlers that intercept BaseException or all exceptions
 *              without re-raising, potentially mishandling system exits and interrupts.
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
 * Determines if an exception handler fails to re-raise the caught exception.
 * This is verified by checking if the handler's basic block reaches an exit point.
 */
predicate doesNotReraise(ExceptStmt exceptBlock) { 
  exceptBlock.getAFlowNode()
             .getBasicBlock()
             .reachesExit() 
}

/**
 * Checks if an exception handler catches BaseException or all exceptions.
 * Two scenarios are covered:
 * 1. Explicitly catching BaseException
 * 2. Using a bare except clause (catches all exceptions)
 */
predicate catchesBaseExceptionOrAll(ExceptStmt exceptBlock) {
  (
    // Explicitly catches BaseException
    exceptBlock.getType() = API::builtin("BaseException")
                                 .getAValueReachableFromSource()
                                 .asExpr()
  )
  or
  (
    // Bare except clause catches all exceptions
    not exists(exceptBlock.getType())
  )
}

// Core query: Find exception handlers that catch BaseException or all exceptions
// and do not re-raise them
from ExceptStmt exceptHandler
where
  catchesBaseExceptionOrAll(exceptHandler) and  // Catches BaseException or all exceptions
  doesNotReraise(exceptHandler)                // Does not re-raise the exception
select exceptHandler, "Except block directly handles BaseException."