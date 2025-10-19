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
 * Determines if an exception handler catches BaseException or any exception.
 * This covers two cases: 
 * 1. The handler explicitly specifies BaseException as the caught type.
 * 2. The handler uses a bare except clause, which catches all exceptions.
 */
predicate capturesBaseException(ExceptStmt exceptHandler) {
  // Case 1: Explicit BaseException capture
  exceptHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Case 2: Bare except clause (catch-all)
  not exists(exceptHandler.getType())
}

/**
 * Checks whether an exception handler does not re-raise the caught exception.
 * This is determined by verifying that the control flow can exit the handler 
 * without executing a re-raise statement.
 */
predicate lacksReraiseMechanism(ExceptStmt exceptHandler) { 
  exceptHandler.getAFlowNode().getBasicBlock().reachesExit() 
}

// Main query: Identify problematic exception handlers
from ExceptStmt exceptHandler
where
  lacksReraiseMechanism(exceptHandler) and  // Lacks re-raise mechanism
  capturesBaseException(exceptHandler)      // Captures BaseException or all exceptions
select exceptHandler, "Except block directly handles BaseException."