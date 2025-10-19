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
 * Predicate to determine if a function contains at least one explicit return statement
 * that returns a non-None value. This indicates the function is designed to return
 * meaningful data in some code paths.
 */
predicate hasExplicitNonNullReturn(Function func) {
  // Check for existence of a return statement within the function scope
  // that has a value expression which is not None
  exists(Return returnStmt |
    returnStmt.getScope() = func and
    exists(Expr returnValue | returnValue = returnStmt.getValue() | not returnValue instanceof None)
  )
}

/**
 * Predicate to determine if a function has implicit return behavior.
 * This occurs in two scenarios:
 * 1. The function has a fallthrough node that is likely reachable
 * 2. The function contains a return statement without a value
 */
predicate hasImplicitReturn(Function func) {
  // First condition: Check for reachable fallthrough node
  exists(ControlFlowNode fallthroughNode |
    fallthroughNode = func.getFallthroughNode() and 
    not fallthroughNode.unlikelyReachable()
  )
  // Second condition: Check for return statements without explicit values
  or
  exists(Return returnStmt | 
    returnStmt.getScope() = func and 
    not exists(returnStmt.getValue())
  )
}

// Main query: Identify functions that mix both explicit non-None returns
// and implicit returns, which can lead to inconsistent return types
from Function targetFunction
where 
  hasExplicitNonNullReturn(targetFunction) and 
  hasImplicitReturn(targetFunction)
select targetFunction,
  "Mixing implicit and explicit returns may indicate an error as implicit returns always return None."