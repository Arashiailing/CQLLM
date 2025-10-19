/**
 * @name Except block handles 'BaseException'
 * @description Identifies exception handling blocks that catch BaseException or all exceptions
 *              without re-raising them, potentially mis-handling system exits and keyboard interrupts.
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
 * Checks if an exception handling block catches BaseException or all exceptions.
 * Two cases are considered:
 * 1. Explicitly catching BaseException
 * 2. Using a bare except clause (catching all exceptions)
 */
predicate capturesBaseException(ExceptStmt exceptionHandler) {
  // Explicitly catches BaseException
  exceptionHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Bare except clause catches all exceptions
  not exists(exceptionHandler.getType())
}

/**
 * Determines if an exception handling block does not re-raise the caught exception.
 * This is verified by checking if the basic block of the exception handler
 * can reach an exit point.
 */
predicate lacksReraise(ExceptStmt exceptionHandler) { 
  exceptionHandler.getAFlowNode().getBasicBlock().reachesExit() 
}

// Main query: Find exception blocks that catch BaseException or all exceptions
// and do not re-raise them
from ExceptStmt exceptionHandler
where
  capturesBaseException(exceptionHandler) and  // Catches BaseException or all exceptions
  lacksReraise(exceptionHandler)              // Does not re-raise the exception
select exceptionHandler, "Except block directly handles BaseException."