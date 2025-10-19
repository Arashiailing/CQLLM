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
 * Checks if an exception handler catches BaseException or all exceptions.
 * This predicate evaluates two possible scenarios:
 * 1. The handler explicitly captures BaseException through type specification
 * 2. The handler uses a bare except clause which implicitly catches all exceptions
 */
predicate handlesBaseException(ExceptStmt exceptionBlock) {
  // Scenario 1: Explicit BaseException capture
  exceptionBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Scenario 2: Bare except clause (catch-all)
  not exists(exceptionBlock.getType())
}

/**
 * Verifies if an exception handler fails to re-raise the caught exception.
 * This is determined by checking if the control flow within the handler
 * can reach an exit point without encountering a re-raise operation.
 */
predicate failsToReraise(ExceptStmt exceptionBlock) { 
  exceptionBlock.getAFlowNode().getBasicBlock().reachesExit() 
}

// Main query: Identify problematic exception handlers
from ExceptStmt exceptionBlock
where
  handlesBaseException(exceptionBlock) and  // Catches BaseException or all exceptions
  failsToReraise(exceptionBlock)           // Lacks re-raise mechanism
select exceptionBlock, "Except block directly handles BaseException."