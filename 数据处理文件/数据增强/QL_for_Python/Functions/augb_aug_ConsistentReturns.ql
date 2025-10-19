/**
 * @name Explicit returns mixed with implicit (fall through) returns
 * @description Detects functions that combine explicit value returns with implicit returns,
 *              which always return None and may indicate inconsistent return behavior.
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
  // Verify existence of a return statement within function scope
  // containing a value expression that is not None
  exists(Return returnStatement |
    returnStatement.getScope() = func and
    exists(Expr returnedValue | 
      returnedValue = returnStatement.getValue() | 
      not returnedValue instanceof None
    )
  )
}

/**
 * Identifies functions with implicit return behavior through either:
 * 1. Reachable fallthrough execution paths
 * 2. Return statements without explicit values
 */
predicate hasImplicitReturn(Function func) {
  // Condition 1: Check for reachable fallthrough node
  exists(ControlFlowNode fallThroughNode |
    fallThroughNode = func.getFallthroughNode() and 
    not fallThroughNode.unlikelyReachable()
  )
  // Condition 2: Check for value-less return statements
  or
  exists(Return returnStatement | 
    returnStatement.getScope() = func and 
    not exists(returnStatement.getValue())
  )
}

// Main query: Detect functions combining explicit non-None returns
// with implicit returns, potentially causing inconsistent return types
from Function funcToCheck
where 
  hasExplicitNonNullReturn(funcToCheck) and 
  hasImplicitReturn(funcToCheck)
select funcToCheck,
  "Mixing implicit and explicit returns may indicate an error as implicit returns always return None."