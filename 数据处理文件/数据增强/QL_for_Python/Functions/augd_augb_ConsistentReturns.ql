import python

/**
 * @name Explicit returns mixed with implicit (fall through) returns
 * @description Identifies functions that combine both explicit return statements and implicit returns.
 *              This pattern often indicates a logic error since implicit returns always evaluate to 'None',
 *              potentially causing unexpected behavior when different return types are expected.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/mixed-returns
 */

// Predicate to identify functions containing explicit return statements with non-None values
predicate has_explicit_non_none_return(Function func) {
  exists(Return returnStmt |
    returnStmt.getScope() = func and
    exists(Expr returnValue | 
      returnValue = returnStmt.getValue() and 
      not returnValue instanceof None
    )
  )
}

// Predicate to determine if a function has implicit return paths
predicate has_implicit_return_path(Function func) {
  // Check for fallthrough nodes that are reachable during execution
  exists(ControlFlowNode fallthroughNode |
    fallthroughNode = func.getFallthroughNode() and 
    not fallthroughNode.unlikelyReachable()
  )
  // Also consider return statements without explicit values
  or
  exists(Return returnStmt | 
    returnStmt.getScope() = func and 
    not exists(returnStmt.getValue())
  )
}

// Query to find functions that exhibit both explicit non-None returns and implicit returns
from Function func
where has_explicit_non_none_return(func) and has_implicit_return_path(func)
select func,
  "Mixing implicit and explicit returns may indicate an error as implicit returns always return None."