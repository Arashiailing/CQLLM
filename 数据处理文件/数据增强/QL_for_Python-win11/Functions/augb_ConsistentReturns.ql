/**
 * @name Explicit returns mixed with implicit (fall through) returns
 * @description Detects functions that combine explicit and implicit returns, which often indicates a logic error since implicit returns always yield 'None'.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/mixed-returns
 */

import python

// Predicate that identifies functions containing explicit return statements with non-None values
predicate explicitly_returns_non_none(Function targetFunction) {
  // Look for return statements within the function scope that return values other than None
  exists(Return retNode |
    retNode.getScope() = targetFunction and
    exists(Expr returnedValue | returnedValue = retNode.getValue() | not returnedValue instanceof None)
  )
}

// Predicate that determines if a function has implicit return paths
predicate has_implicit_return(Function targetFunction) {
  // Check for fallthrough nodes that are reachable during execution
  exists(ControlFlowNode fallThroughNode |
    fallThroughNode = targetFunction.getFallthroughNode() and not fallThroughNode.unlikelyReachable()
  )
  // Also consider return statements without explicit values
  or
  exists(Return retNode | retNode.getScope() = targetFunction and not exists(retNode.getValue()))
}

// Query to find functions that exhibit both explicit non-None returns and implicit returns
from Function targetFunction
where explicitly_returns_non_none(targetFunction) and has_implicit_return(targetFunction)
select targetFunction,
  "Mixing implicit and explicit returns may indicate an error as implicit returns always return None."