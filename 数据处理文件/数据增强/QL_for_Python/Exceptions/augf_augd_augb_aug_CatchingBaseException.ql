/**
 * @name Exception block catches 'BaseException'
 * @description Capturing 'BaseException' can lead to improper handling of system exits and keyboard interrupts.
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

// Determines if an exception handler captures BaseException or has no type specified
predicate handlesBaseException(ExceptStmt exceptionHandler) {
  // Check if exception type is BaseException or if no type is defined
  exceptionHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  not exists(exceptionHandler.getType())
}

// Evaluates whether an exception handler fails to re-raise the caught exception
predicate suppressesException(ExceptStmt exceptionHandler) { 
  // Examine control flow to determine if the handler's basic block reaches program exit
  exceptionHandler.getAFlowNode().getBasicBlock().reachesExit() 
}

// Main query: Identify exception handlers that catch BaseException without re-raising
from ExceptStmt exceptionHandler
where
  handlesBaseException(exceptionHandler) and // Condition: Handler catches BaseException or any exception
  suppressesException(exceptionHandler) // Condition: Handler does not re-raise the exception
select exceptionHandler, "Except block directly handles BaseException." // Output the problematic handler with description