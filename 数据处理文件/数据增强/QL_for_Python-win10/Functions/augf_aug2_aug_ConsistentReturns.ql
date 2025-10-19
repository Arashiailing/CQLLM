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
 * Detects functions that contain at least one explicit return statement
 * returning a non-None value, demonstrating intentional data return behavior.
 */
predicate containsExplicitNonNullReturn(Function func) {
  // Confirm presence of return statements within the function's scope
  // that return values other than None
  exists(Return returnStmt |
    returnStmt.getScope() = func and
    exists(Expr returnValue | returnValue = returnStmt.getValue() | not returnValue instanceof None)
  )
}

/**
 * Identifies functions with return statements that lack explicit values,
 * which implicitly return None.
 */
predicate hasValuelessReturn(Function func) {
  exists(Return returnStmt | 
    returnStmt.getScope() = func and 
    not exists(returnStmt.getValue())
  )
}

/**
 * Determines if a function has reachable fallthrough control flow nodes,
 * which cause implicit None returns at the end of execution.
 */
predicate hasReachableFallthrough(Function func) {
  exists(ControlFlowNode fallthroughNode |
    fallthroughNode = func.getFallthroughNode() and 
    not fallthroughNode.unlikelyReachable()
  )
}

/**
 * Combines detection of both types of implicit returns:
 * valueless return statements and reachable fallthrough nodes.
 */
predicate exhibitsImplicitReturnBehavior(Function func) {
  hasValuelessReturn(func) or hasReachableFallthrough(func)
}

// Main analysis: Identify functions that demonstrate both explicit non-None returns
// and implicit returns, leading to inconsistent return type patterns
from Function problematicFunction
where 
  containsExplicitNonNullReturn(problematicFunction) and 
  exhibitsImplicitReturnBehavior(problematicFunction)
select problematicFunction,
  "Mixing implicit and explicit returns may indicate an error as implicit returns always return None."