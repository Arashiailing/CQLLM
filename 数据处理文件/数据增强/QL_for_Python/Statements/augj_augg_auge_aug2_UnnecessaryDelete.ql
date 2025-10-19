/**
 * @name Unnecessary delete statement in function
 * @description Detects redundant 'delete' statements for local variables,
 *              since they are automatically destroyed when the function exits.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/unnecessary-delete
 */

import python

/**
 * Determines whether a given AST node is contained within any loop construct,
 * either directly or through nested containment in parent nodes.
 */
predicate withinLoopContext(AstNode node) {
  // Check for immediate loop parent
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  or
  // Check for nested containment in loops
  exists(AstNode parentNode | 
    withinLoopContext(parentNode) and 
    node = parentNode.getAChildNode()
  )
}

// Identify unnecessary delete operations on local variables
from Delete deletionOperation, Expr targetExpression, Function containingFunction
where
  // Constraint: Must be the last statement in the function
  containingFunction.getLastStatement() = deletionOperation
  and
  // Constraint: Must target a specific expression
  targetExpression = deletionOperation.getATarget()
  and
  // Constraint: Target must be in the function's scope
  containingFunction.containsInScope(targetExpression)
  and
  // Constraint: Target must not be a complex access pattern
  not targetExpression instanceof Subscript
  and
  not targetExpression instanceof Attribute
  and
  // Constraint: Must not be within any loop structure
  not withinLoopContext(deletionOperation)
  and
  // Constraint: Function must not use exception handling via sys.exc_info()
  not exists(FunctionValue exceptionInfoCall |
    exceptionInfoCall = Value::named("sys.exc_info") and
    exceptionInfoCall.getACall().getScope() = containingFunction
  )
select deletionOperation, "Unnecessary deletion of local variable $@ in function $@.", targetExpression, targetExpression.toString(), containingFunction,
  containingFunction.getName()