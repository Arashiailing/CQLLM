/**
 * @name Exception block catches 'BaseException'
 * @description Identifies exception handling blocks that catch 'BaseException' without
 *              re-raising, potentially masking system-critical events like exits and
 *              keyboard interrupts.
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

// Evaluates whether an exception handling block lacks re-raise mechanism
predicate lacksReraise(ExceptStmt exceptionBlock) { 
  // Confirm that the control flow of the exception block reaches program exit
  // without encountering a re-raise statement
  exceptionBlock.getAFlowNode().getBasicBlock().reachesExit() 
}

// Determines if an exception handling block catches BaseException or uses bare except
predicate catchesBaseException(ExceptStmt exceptionBlock) {
  // Block explicitly catches BaseException type
  exceptionBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Block employs bare except clause (catches all exceptions including BaseException)
  not exists(exceptionBlock.getType())
}

// Main query logic: Identify exception blocks that catch BaseException without re-raising
from ExceptStmt exceptionBlock
where
  /* Condition 1: Block catches BaseException or uses bare except */
  catchesBaseException(exceptionBlock) and
  /* Condition 2: Block does not re-raise the caught exception */
  lacksReraise(exceptionBlock)
select exceptionBlock, "Except block directly handles BaseException."