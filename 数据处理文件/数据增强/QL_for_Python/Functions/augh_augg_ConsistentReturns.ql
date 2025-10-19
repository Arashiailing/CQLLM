/**
 * @name Explicit returns mixed with implicit (fall through) returns
 * @description Identifies functions that combine explicit return statements with implicit returns,
 *              which can cause unexpected behavior since implicit returns always yield None.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/mixed-returns
 */

import python

// Predicate to identify functions containing explicit return statements that yield non-None values
predicate explicitly_returns_non_none(Function func) {
  // Verify existence of a return statement within the function scope that returns a non-None value
  exists(Return returnStmt |
    returnStmt.getScope() = func and
    exists(Expr returnedValue | 
      returnedValue = returnStmt.getValue() and 
      not returnedValue instanceof None
    )
  )
}

// Predicate to identify functions with implicit return paths
predicate has_implicit_return(Function func) {
  // A function has implicit returns if either:
  // 1. It contains a reachable fallthrough node, or
  // 2. It includes return statements without explicit values
  (exists(ControlFlowNode fallThroughNode |
    fallThroughNode = func.getFallthroughNode() and 
    not fallThroughNode.unlikelyReachable()
  ))
  or
  (exists(Return returnStmt | 
    returnStmt.getScope() = func and 
    not exists(returnStmt.getValue())
  ))
}

// Select functions that both explicitly return non-None values and have implicit return paths
from Function func
where explicitly_returns_non_none(func) and has_implicit_return(func)
select func,
  "Mixing implicit and explicit returns may indicate an error as implicit returns always return None."