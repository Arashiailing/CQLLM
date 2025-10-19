/**
 * @name Explicit returns mixed with implicit (fall through) returns
 * @description Detects functions that mix explicit return statements with implicit returns,
 *              which can lead to inconsistent return types since implicit returns always return 'None'.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/mixed-returns
 */

import python

/**
 * Determines whether a function contains at least one explicit return statement
 * that returns a non-None value, indicating the function is designed to return
 * meaningful data in certain execution paths.
 */
predicate hasExplicitNonNullReturn(Function func) {
  // Verify existence of a return statement within the function scope
  // that has a value expression which is not None
  exists(Return retStmt |
    retStmt.getScope() = func and
    exists(Expr retValue | retValue = retStmt.getValue() | not retValue instanceof None)
  )
}

/**
 * Identifies functions with implicit return behavior, which occurs when:
 * 1. The function has a reachable fallthrough node, or
 * 2. The function contains return statements without explicit values
 */
predicate hasImplicitReturn(Function func) {
  // First condition: Check for reachable fallthrough node
  exists(ControlFlowNode fallthrough |
    fallthrough = func.getFallthroughNode() and 
    not fallthrough.unlikelyReachable()
  )
  // Second condition: Check for return statements without explicit values
  or
  exists(Return retStmt | 
    retStmt.getScope() = func and 
    not exists(retStmt.getValue())
  )
}

// Main query: Find functions that combine both explicit non-None returns
// and implicit returns, potentially causing inconsistent return types
from Function funcWithMixedReturns
where 
  hasExplicitNonNullReturn(funcWithMixedReturns) and 
  hasImplicitReturn(funcWithMixedReturns)
select funcWithMixedReturns,
  "Mixing implicit and explicit returns may indicate an error as implicit returns always return None."