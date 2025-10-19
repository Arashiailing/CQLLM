/**
 * @name Exception handler catches BaseException
 * @description Detects exception handlers that intercept 'BaseException' without re-raising,
 *              which may lead to improper handling of system exits and keyboard interrupts.
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
 * Identifies problematic exception handlers that catch BaseException or use bare except,
 * and fail to re-raise the caught exception. This combines both detection conditions:
 * 1. Handler catches BaseException explicitly or via bare except clause
 * 2. Handler's control flow reaches program exit without re-raising
 */
predicate isProblematicExceptBlock(ExceptStmt exceptBlock) {
  // Check for BaseException capture (explicit or bare except)
  (exceptBlock.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
   or 
   not exists(exceptBlock.getType()))
  and
  // Verify control flow reaches exit without re-raising
  exceptBlock.getAFlowNode().getBasicBlock().reachesExit()
}

// Main query: Identify exception blocks with problematic BaseException handling
from ExceptStmt exceptBlock
where isProblematicExceptBlock(exceptBlock)
select exceptBlock, "Except block directly handles BaseException."