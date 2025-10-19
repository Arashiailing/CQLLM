/**
 * @name Explicit returns mixed with implicit (fall through) returns
 * @description This rule identifies functions that mix both explicit returns (returning non-None values)
 *              and implicit returns (falling off the end of the function or using return without a value).
 *              Such mixing can lead to unexpected behavior since implicit returns always yield None.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/mixed-returns
 */

import python

// Predicate to determine if a function contains at least one explicit return statement
// that returns a non-None value
predicate hasExplicitNonNullReturn(Function function) {
  exists(Return ret_stmt |
    // The return statement must be within the function's scope
    ret_stmt.getScope() = function and
    // The return statement must have a value
    exists(Expr ret_val | 
      ret_val = ret_stmt.getValue() and 
      // The returned value must not be None
      not ret_val instanceof None
    )
  )
}

// Predicate to determine if a function has implicit return behavior,
// which can occur either through fallthrough or return statements without values
predicate hasImplicitReturn(Function function) {
  // First condition: Check for reachable fallthrough nodes
  (exists(ControlFlowNode fallthrough_node | 
    fallthrough_node = function.getFallthroughNode() and 
    not fallthrough_node.unlikelyReachable()
  ))
  // Second condition: Check for return statements without explicit values
  or
  (exists(Return ret_stmt | 
    ret_stmt.getScope() = function and 
    not exists(ret_stmt.getValue())
  ))
}

// Main query to find functions that mix explicit non-None returns with implicit returns
from Function function
where hasExplicitNonNullReturn(function) and hasImplicitReturn(function)
select function,
  "Mixing implicit and explicit returns may indicate an error as implicit returns always return None."