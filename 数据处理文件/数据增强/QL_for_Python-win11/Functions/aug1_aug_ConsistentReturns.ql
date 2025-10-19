/**
 * @name Explicit returns mixed with implicit (fall through) returns
 * @description Mixing implicit and explicit returns indicates a likely error as implicit returns always return 'None'.
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
 * Determines if a function contains at least one explicit return statement
 * that returns a non-None value, indicating the function is designed to return
 * meaningful data in certain code paths.
 */
predicate hasExplicitNonNullReturn(Function targetFunc) {
  // Verify existence of a return statement within the function scope
  // that has a value expression which is not None
  exists(Return retStmt |
    retStmt.getScope() = targetFunc and
    exists(Expr retValue | retValue = retStmt.getValue() | not retValue instanceof None)
  )
}

/**
 * Identifies functions with implicit return behavior through two scenarios:
 * 1. Presence of a reachable fallthrough node
 * 2. Existence of return statements without explicit values
 */
predicate hasImplicitReturn(Function targetFunc) {
  // Check for return statements without explicit values
  exists(Return retStmt | 
    retStmt.getScope() = targetFunc and 
    not exists(retStmt.getValue())
  )
  // Check for reachable fallthrough node
  or
  exists(ControlFlowNode fallNode |
    fallNode = targetFunc.getFallthroughNode() and 
    not fallNode.unlikelyReachable()
  )
}

// Main query: Detect functions mixing explicit non-None returns
// with implicit returns, leading to inconsistent return types
from Function targetFunc
where 
  hasExplicitNonNullReturn(targetFunc) and 
  hasImplicitReturn(targetFunc)
select targetFunc,
  "Mixing implicit and explicit returns may indicate an error as implicit returns always return None."