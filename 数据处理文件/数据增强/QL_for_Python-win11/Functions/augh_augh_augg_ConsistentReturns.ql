/**
 * @name Explicit returns mixed with implicit (fall through) returns
 * @description Detects functions combining explicit return statements with implicit returns,
 *              which may cause unexpected behavior since implicit returns always yield None.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/mixed-returns
 */

import python

// Identifies functions containing return statements that explicitly yield non-None values
predicate returns_non_none_explicitly(Function func) {
  // Check for existence of a return statement within the function scope returning non-None
  exists(Return ret |
    ret.getScope() = func and
    exists(Expr retVal | 
      retVal = ret.getValue() and 
      not retVal instanceof None
    )
  )
}

// Identifies functions with potential implicit return paths
predicate contains_implicit_return(Function func) {
  // Implicit returns occur when:
  // 1. The function has a reachable fallthrough node, or
  // 2. It contains return statements without explicit values
  (exists(ControlFlowNode fallThrough |
    fallThrough = func.getFallthroughNode() and 
    not fallThrough.unlikelyReachable()
  ))
  or
  (exists(Return ret | 
    ret.getScope() = func and 
    not exists(ret.getValue())
  ))
}

// Select functions that both explicitly return non-None values and have implicit return paths
from Function func
where returns_non_none_explicitly(func) and contains_implicit_return(func)
select func,
  "Mixing implicit and explicit returns may indicate an error as implicit returns always return None."