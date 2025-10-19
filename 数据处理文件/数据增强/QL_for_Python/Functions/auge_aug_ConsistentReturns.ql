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
 * Determines if a function contains explicit return statements
 * with non-None values, indicating intentional data return behavior.
 */
predicate hasExplicitNonNullReturn(Function func) {
  // Verify existence of return statements in function scope
  // that return values other than None
  exists(Return ret |
    ret.getScope() = func and
    exists(Expr valExpr | valExpr = ret.getValue() | not valExpr instanceof None)
  )
}

/**
 * Identifies functions exhibiting implicit return behavior through:
 * 1. Reachable fallthrough nodes (implicit None returns)
 * 2. Valueless return statements (explicit None returns)
 */
predicate hasImplicitReturn(Function func) {
  // Check for potentially reachable fallthrough nodes
  exists(ControlFlowNode fallNode |
    fallNode = func.getFallthroughNode() and 
    not fallNode.unlikelyReachable()
  )
  // Or check for return statements without explicit values
  or
  exists(Return ret | 
    ret.getScope() = func and 
    not exists(ret.getValue())
  )
}

// Identify functions combining explicit non-None returns with
// implicit returns, creating inconsistent return type behavior
from Function targetFunc
where 
  hasExplicitNonNullReturn(targetFunc) and 
  hasImplicitReturn(targetFunc)
select targetFunc,
  "Mixing implicit and explicit returns may indicate an error as implicit returns always return None."