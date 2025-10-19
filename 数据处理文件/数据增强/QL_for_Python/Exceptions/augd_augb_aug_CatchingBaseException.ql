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
predicate catchesBaseException(ExceptStmt exceptBlock) {
  // Check if exception type is BaseException or if no type is defined
  exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  not exists(exceptBlock.getType())
}

// Evaluates whether an exception handler fails to re-raise the caught exception
predicate doesNotReraiseException(ExceptStmt exceptBlock) { 
  // Examine control flow to determine if the handler's basic block reaches program exit
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit() 
}

// Main query: Identify exception handlers that catch BaseException without re-raising
from ExceptStmt exceptBlock
where
  catchesBaseException(exceptBlock) and // Condition: Handler catches BaseException or any exception
  doesNotReraiseException(exceptBlock) // Condition: Handler does not re-raise the exception
select exceptBlock, "Except block directly handles BaseException." // Output the problematic handler with description