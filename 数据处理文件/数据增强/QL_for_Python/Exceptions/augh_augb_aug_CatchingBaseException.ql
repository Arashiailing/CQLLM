/**
 * @name Exception block catches 'BaseException'
 * @description Detects exception handlers that catch BaseException without re-raising,
 *              which can lead to improper handling of system exits and keyboard interrupts.
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

// Determines if an exception handler does not re-raise the caught exception
predicate noReraiseInHandler(ExceptStmt exceptionBlock) { 
  // Check if the basic block containing the exception handler reaches program exit
  exceptionBlock.getAFlowNode().getBasicBlock().reachesExit() 
}

// Checks if an exception handler catches BaseException or has no exception type specified
predicate catchesBaseException(ExceptStmt exceptionBlock) {
  // Verify if the exception type is BaseException or if no type is defined
  exceptionBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  not exists(exceptionBlock.getType())
}

// Main query: Identify exception handlers that catch BaseException without re-raising it
from ExceptStmt exceptionBlock
where
  // Conditions: Catches BaseException and lacks re-raise mechanism
  catchesBaseException(exceptionBlock) and
  noReraiseInHandler(exceptionBlock)
select exceptionBlock, "Except block directly handles BaseException." // Output selection with description