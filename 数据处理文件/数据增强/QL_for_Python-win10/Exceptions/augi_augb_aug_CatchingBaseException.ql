/**
 * @name Exception block catches 'BaseException'
 * @description Detects exception handlers that catch 'BaseException' without re-raising, which may 
 *              improperly handle system exits and keyboard interrupts.
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
predicate doesNotReraiseException(ExceptStmt exceptionHandler) { 
  // Analyze control flow to verify if the handler's basic block leads to program exit
  exceptionHandler.getAFlowNode().getBasicBlock().reachesExit() 
}

// Checks whether an exception handler captures BaseException or has no specific type
predicate catchesBaseException(ExceptStmt exceptionHandler) {
  // Verify if the exception type is BaseException or if no type is specified
  exceptionHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  not exists(exceptionHandler.getType())
}

// Primary query: Identify exception handlers that catch BaseException without re-raising
from ExceptStmt exceptionHandler
where
  catchesBaseException(exceptionHandler) and // Condition: Handler catches BaseException
  doesNotReraiseException(exceptionHandler)  // Condition: No re-raise mechanism implemented
select exceptionHandler, "Except block directly handles BaseException." // Output with description