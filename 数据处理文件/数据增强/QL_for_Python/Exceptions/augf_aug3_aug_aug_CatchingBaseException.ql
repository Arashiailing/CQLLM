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
 * Determines if an exception handling block lacks a re-raise mechanism.
 * This is verified by analyzing the control flow to ensure it can reach
 * an exit point without encountering a re-raise operation.
 */
predicate lacksReraiseMechanism(ExceptStmt exceptionBlock) { 
  exceptionBlock.getAFlowNode().getBasicBlock().reachesExit() 
}

/**
 * Checks if an exception handling block captures BaseException or all exceptions.
 * This includes two scenarios:
 * 1. Explicitly capturing BaseException through type specification
 * 2. Using a bare except clause (implicitly captures all exceptions)
 */
predicate capturesBaseException(ExceptStmt exceptionBlock) {
  // Case 1: Explicit BaseException capture
  exceptionBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Case 2: Bare except clause (catch-all)
  not exists(exceptionBlock.getType())
}

// Main query: Identify problematic exception handlers
from ExceptStmt exceptionBlock
where
  capturesBaseException(exceptionBlock) and  // Captures BaseException or all exceptions
  lacksReraiseMechanism(exceptionBlock)     // Lacks re-raise mechanism
select exceptionBlock, "Except block directly handles BaseException."