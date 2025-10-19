/**
 * @name Exception block catches 'BaseException'
 * @description Detects exception handlers that catch 'BaseException' without re-raising,
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

/**
 * Determines if an exception handler does not re-raise the caught exception.
 * This predicate checks if the control flow from the handler reaches the program exit
 * without re-raising the exception.
 */
predicate isNotReraising(ExceptStmt exceptBlock) { 
  // Verify that the handler's control flow reaches program exit without re-raising
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit() 
}

/**
 * Checks if an exception handler catches BaseException or uses a bare except clause.
 * This predicate identifies handlers that catch the base exception class or all exceptions.
 */
predicate capturesBaseException(ExceptStmt exceptBlock) {
  // Handler explicitly catches BaseException type
  exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Handler uses bare except clause (catches all exceptions including BaseException)
  not exists(exceptBlock.getType())
}

// Main query logic: Identify problematic exception handlers
from ExceptStmt exceptBlock
where
  // The handler catches BaseException or uses bare except
  capturesBaseException(exceptBlock) and
  // The handler does not re-raise the caught exception
  isNotReraising(exceptBlock)
select exceptBlock, "Except block directly handles BaseException."