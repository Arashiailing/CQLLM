/**
 * @name Exception handler catches BaseException without re-raising
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
 * Checks if an exception handler catches BaseException or all exceptions.
 * Two scenarios are considered:
 * 1. Explicitly catching BaseException
 * 2. Using a bare except clause (catching all exceptions)
 */
predicate catchesBaseException(ExceptStmt exceptBlock) {
  // Explicitly catches BaseException
  exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Bare except clause catches all exceptions
  not exists(exceptBlock.getType())
}

/**
 * Determines if an exception handler fails to re-raise the caught exception.
 * This is verified by checking if the handler's basic block can reach an exit point.
 */
predicate noReraise(ExceptStmt exceptBlock) { 
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit() 
}

// Main query: Find exception handlers that catch BaseException or all exceptions
// and do not re-raise them
from ExceptStmt exceptBlock
where
  catchesBaseException(exceptBlock) and  // Catches BaseException or all exceptions
  noReraise(exceptBlock)                // Does not re-raise the exception
select exceptBlock, "Except block directly handles BaseException."