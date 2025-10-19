/**
 * @name Exception block catches 'BaseException'
 * @description Capturing 'BaseException' can lead to improper handling of system exits
 *              and keyboard interrupts, as it is the base class for all built-in exceptions.
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

// Determines if an exception handler catches BaseException or has no specific exception type
predicate catchesBaseOrGenericException(ExceptStmt exceptBlock) {
  // Check if the exception type is BaseException
  exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Or if no exception type is specified (catches all exceptions)
  not exists(exceptBlock.getType())
}

// Checks if an exception handler fails to re-raise the caught exception
predicate doesNotReraiseException(ExceptStmt exceptBlock) {
  // Analyze control flow to see if the handler's basic block reaches program exit
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit()
}

// Main query: Identify exception handlers that catch BaseException without re-raising
from ExceptStmt exceptBlock
where
  catchesBaseOrGenericException(exceptBlock) and // Condition: Catches BaseException or all exceptions
  doesNotReraiseException(exceptBlock)           // Condition: Does not re-raise the exception
select exceptBlock, "Except block directly handles BaseException without re-raising." // Output selection with description