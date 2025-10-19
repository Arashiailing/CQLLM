/**
 * @name Explicit returns mixed with implicit (fall through) returns
 * @description Detects functions that mix explicit return statements with implicit returns,
 *              which can lead to unexpected behavior since implicit returns always yield None.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/mixed-returns
 */

import python

// Predicate to determine if a function contains explicit return statements that yield non-None values
predicate explicitly_returns_non_none(Function func) {
  // Check for existence of a return statement within the function's scope that returns a non-None value
  exists(Return retStmt |
    retStmt.getScope() = func and
    exists(Expr returnValue | returnValue = retStmt.getValue() | not returnValue instanceof None)
  )
}

// Predicate to determine if a function has implicit return paths
predicate has_implicit_return(Function func) {
  // A function has an implicit return if either:
  // 1. It has a fallthrough node that is likely to be reached, or
  // 2. It contains return statements without explicit values
  (exists(ControlFlowNode fallthroughNode |
    fallthroughNode = func.getFallthroughNode() and not fallthroughNode.unlikelyReachable()
  ))
  or
  (exists(Return retStmt | 
    retStmt.getScope() = func and not exists(retStmt.getValue())
  ))
}

// Select functions that both explicitly return non-None values and have implicit return paths
from Function func
where explicitly_returns_non_none(func) and has_implicit_return(func)
select func,
  "Mixing implicit and explicit returns may indicate an error as implicit returns always return None."