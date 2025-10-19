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
 * Identifies functions containing at least one explicit return statement
 * that returns a non-None value, indicating intentional data return behavior.
 */
predicate hasExplicitNonNullReturn(Function func) {
  // Verify existence of return statement within function scope
  // where the returned value is not None
  exists(Return retStmt |
    retStmt.getScope() = func and
    exists(Expr retVal | retVal = retStmt.getValue() | not retVal instanceof None)
  )
}

/**
 * Detects functions with implicit return behavior through either:
 * 1. Reachable fallthrough control flow nodes
 * 2. Return statements without explicit values
 */
predicate hasImplicitReturn(Function func) {
  // Check for return statements lacking explicit values
  exists(Return retStmt | 
    retStmt.getScope() = func and 
    not exists(retStmt.getValue())
  )
  // OR check for reachable fallthrough nodes
  or
  exists(ControlFlowNode fallNode |
    fallNode = func.getFallthroughNode() and 
    not fallNode.unlikelyReachable()
  )
}

// Core analysis: Locate functions exhibiting both explicit non-None returns
// and implicit returns, creating inconsistent return type behavior
from Function targetFunction
where 
  hasExplicitNonNullReturn(targetFunction) and 
  hasImplicitReturn(targetFunction)
select targetFunction,
  "Mixing implicit and explicit returns may indicate an error as implicit returns always return None."