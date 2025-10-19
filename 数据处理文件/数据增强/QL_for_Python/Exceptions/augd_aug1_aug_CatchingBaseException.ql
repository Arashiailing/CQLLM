/**
 * @name Exception block catches 'BaseException'
 * @description Identifies exception handlers that catch 'BaseException' without re-raising,
 *              potentially leading to improper handling of system exits and keyboard interrupts.
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

// Evaluates whether an exception handler fails to re-raise the caught exception
predicate doesNotReraiseException(ExceptStmt exceptBlock) { 
  // Confirm that the handler's control flow path leads to program exit without re-raising
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit() 
}

// Determines if an exception handler catches BaseException or employs a bare except clause
predicate catchesBaseExceptionType(ExceptStmt exceptBlock) {
  // Handler explicitly targets BaseException type
  exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // Handler utilizes a bare except clause (catches all exceptions, including BaseException)
  not exists(exceptBlock.getType())
}

// Core query: Identify handlers that catch BaseException without re-raising it
from ExceptStmt exceptBlock
where
  /* First condition: Handler catches BaseException or uses bare except */
  catchesBaseExceptionType(exceptBlock) and
  /* Second condition: Handler does not re-raise the exception */
  doesNotReraiseException(exceptBlock)
select exceptBlock, "Except block directly handles BaseException."