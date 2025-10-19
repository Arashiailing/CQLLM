/**
 * @name Unnecessary delete statement in function
 * @description Identifies redundant 'delete' operations on local variables that
 *              are automatically cleaned up when the function exits.
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
 * Determines if an AST node is nested within any loop construct (For or While).
 * This predicate performs a recursive check to identify nodes that are inside
 * loop structures, which is important for determining if a delete statement
 * might be necessary for multiple iterations.
 * 
 * @param node The AST node to check for loop nesting.
 */
predicate isNestedInLoop(AstNode node) {
  // Base case: Node is a direct child of a loop statement
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  // Recursive case: Node is a descendant of another node already identified in a loop
  or
  exists(AstNode loopAncestor | 
    isNestedInLoop(loopAncestor) and 
    node = loopAncestor.getAChildNode()
  )
}

/**
 * Main query to identify unnecessary delete statements at function termination.
 * These delete operations are redundant because local variables are automatically
 * cleaned up when the function exits. The query filters out cases where the delete
 * might be necessary, such as within loops or when dealing with specific system calls.
 */
from Delete deletionStatement, Expr targetExpression, Function containerFunction
where
  // The delete statement must be the final statement in the function
  containerFunction.getLastStatement() = deletionStatement
  and
  // Identify the expression being deleted
  targetExpression = deletionStatement.getATarget()
  and
  // Verify the expression is within the function's scope
  containerFunction.containsInScope(targetExpression)
  and
  // Exclude subscript operations (e.g., del list[0]) as these modify objects rather than just removing references
  not targetExpression instanceof Subscript
  and
  // Exclude attribute access (e.g., del obj.attr) as these modify object state
  not targetExpression instanceof Attribute
  and
  // Exclude deletes within loop constructs as they might be necessary for multiple iterations
  not isNestedInLoop(deletionStatement)
  and
  // Exclude functions with sys.exc_info calls requiring explicit cleanup of exception information
  not exists(FunctionValue sysExcInfoCall |
    sysExcInfoCall = Value::named("sys.exc_info") and
    sysExcInfoCall.getACall().getScope() = containerFunction
  )
select deletionStatement, "Unnecessary deletion of local variable $@ in function $@.", targetExpression, targetExpression.toString(), containerFunction,
  containerFunction.getName()