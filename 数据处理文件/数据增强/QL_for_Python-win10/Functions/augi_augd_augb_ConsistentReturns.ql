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

// Detects functions that have at least one return statement with a non-None value
predicate containsExplicitNonNoneReturn(Function func) {
  exists(Return retStmt |
    retStmt.getScope() = func and
    exists(Expr retValue | 
      retValue = retStmt.getValue() and 
      not retValue instanceof None
    )
  )
}

// Checks if a function contains any implicit return paths (either fallthrough or empty returns)
predicate containsImplicitReturnPath(Function func) {
  // Check for reachable fallthrough nodes
  exists(ControlFlowNode fallThruNode |
    fallThruNode = func.getFallthroughNode() and 
    not fallThruNode.unlikelyReachable()
  )
  // Also check for return statements without values
  or
  exists(Return retStmt | 
    retStmt.getScope() = func and 
    not exists(retStmt.getValue())
  )
}

// Main query to identify functions with both explicit non-None returns and implicit returns
from Function targetFunction
where containsExplicitNonNoneReturn(targetFunction) and containsImplicitReturnPath(targetFunction)
select targetFunction,
  "Mixing implicit and explicit returns may indicate an error as implicit returns always return None."