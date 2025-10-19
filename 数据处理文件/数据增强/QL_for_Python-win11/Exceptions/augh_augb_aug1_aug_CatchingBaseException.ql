/**
 * @name Exception handler catches BaseException
 * @description Identifies exception handlers that catch 'BaseException' without re-raising,
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

/**
 * Holds if the exception handler catches BaseException or uses a bare except clause.
 * This identifies handlers that catch the base exception class or all exceptions.
 */
predicate capturesBaseException(ExceptStmt handler) {
  // Handler explicitly catches BaseException type
  handler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Handler uses bare except clause (catches all exceptions including BaseException)
  not exists(handler.getType())
}

/**
 * Holds if the exception handler does not re-raise the caught exception.
 * This is determined by checking whether the control flow from the handler reaches
 * the program exit without re-raising the exception.
 */
predicate isNotReraising(ExceptStmt handler) { 
  // Verify that the handler's control flow reaches program exit without re-raising
  handler.getAFlowNode().getBasicBlock().reachesExit() 
}

// Main query logic: Identify problematic exception handlers
from ExceptStmt handler
where
  // The handler catches BaseException or uses bare except
  capturesBaseException(handler) and
  // The handler does not re-raise the caught exception
  isNotReraising(handler)
select handler, "Except block directly handles BaseException."