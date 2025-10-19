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
 * Determines if an exception handler lacks re-raise mechanism.
 * Verified by checking if control flow reaches exit without encountering re-raise.
 */
predicate missingReraise(ExceptStmt exceptionBlock) { 
  exceptionBlock.getAFlowNode().getBasicBlock().reachesExit() 
}

/**
 * Checks if exception handler catches BaseException or all exceptions.
 * Covers two scenarios:
 * 1. Explicit BaseException capture via type specification
 * 2. Bare except clause (implicit catch-all)
 */
predicate handlesBaseException(ExceptStmt exceptionBlock) {
  // Explicit BaseException capture
  exceptionBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Bare except clause (catch-all)
  not exists(exceptionBlock.getType())
}

// Main query: Identify problematic exception handlers
from ExceptStmt exceptionBlock
where
  handlesBaseException(exceptionBlock) and  // Catches BaseException or all exceptions
  missingReraise(exceptionBlock)           // Lacks re-raise mechanism
select exceptionBlock, "Except block directly handles BaseException."