/**
 * @name Inconsistent return patterns (explicit vs implicit)
 * @description Functions mixing explicit returns with implicit fallthrough returns
 *              create inconsistent return types since implicit returns always yield None.
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
 * Identifies functions containing return statements that explicitly return non-None values,
 * indicating intentional data return behavior.
 */
predicate hasExplicitNonNullReturn(Function func) {
  // Verify existence of return statements within function scope
  // that return values other than None
  exists(Return retStmt |
    retStmt.getScope() = func and
    exists(Expr retVal | retVal = retStmt.getValue() | not retVal instanceof None)
  )
}

/**
 * Determines if a function exhibits implicit return behavior through either:
 * 1. Valueless return statements (implicitly returning None)
 * 2. Reachable fallthrough nodes (implicitly returning None at execution end)
 */
predicate showsImplicitReturnPattern(Function func) {
  // Case 1: Return statements without explicit values
  exists(Return retStmt | 
    retStmt.getScope() = func and 
    not exists(retStmt.getValue())
  )
  or
  // Case 2: Reachable fallthrough control flow nodes
  exists(ControlFlowNode fallNode |
    fallNode = func.getFallthroughNode() and 
    not fallNode.unlikelyReachable()
  )
}

// Primary analysis: Detect functions with both explicit non-None returns
// and implicit returns, creating inconsistent return type patterns
from Function funcWithMixedReturns
where 
  hasExplicitNonNullReturn(funcWithMixedReturns) and 
  showsImplicitReturnPattern(funcWithMixedReturns)
select funcWithMixedReturns,
  "Mixing implicit and explicit returns may indicate an error as implicit returns always return None."