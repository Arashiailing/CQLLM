/**
 * @name Except block handles 'BaseException'
 * @description Handling 'BaseException' means that system exits and keyboard interrupts may be mis-handled.
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

// Identifies exception handlers that catch BaseException or use bare except clauses
// and fail to re-raise caught exceptions
predicate isProblematicExceptionHandler(ExceptStmt exceptStmt) {
  // Check if handler catches BaseException or uses bare except
  (exceptStmt.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr() 
   or 
   not exists(exceptStmt.getType()))
  and
  // Verify handler allows normal program exit without re-raising
  exceptStmt.getAFlowNode().getBasicBlock().reachesExit()
}

from ExceptStmt exceptStmt
where isProblematicExceptionHandler(exceptStmt)
select exceptStmt, "Except block directly handles BaseException."