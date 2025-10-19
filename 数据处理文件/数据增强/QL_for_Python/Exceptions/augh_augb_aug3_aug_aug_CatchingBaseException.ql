/**
 * @name Except block handles 'BaseException'
 * @description Identifies exception handlers catching BaseException or all exceptions
 *              without re-raising, potentially mis-handling system exits and interrupts.
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
 * Identifies exception handlers that catch BaseException or all exceptions.
 * Covers two scenarios:
 * 1. Explicit BaseException capture through type specification
 * 2. Bare except clause (implicit catch-all)
 */
predicate catchesBaseException(ExceptStmt exceptBlock) {
  // Explicit BaseException capture
  exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Bare except clause (catch-all)
  not exists(exceptBlock.getType())
}

/**
 * Determines if an exception handler lacks re-raise mechanism.
 * Verified by checking if control flow reaches exit without encountering re-raise.
 */
predicate lacksReraise(ExceptStmt exceptBlock) { 
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit() 
}

// Main query: Identify problematic exception handlers
from ExceptStmt problematicExceptBlock
where
  catchesBaseException(problematicExceptBlock) and  // Catches BaseException or all exceptions
  lacksReraise(problematicExceptBlock)            // Lacks re-raise mechanism
select problematicExceptBlock, "Except block directly handles BaseException."