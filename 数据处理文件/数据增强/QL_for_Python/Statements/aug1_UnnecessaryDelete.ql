/**
 * @name Unnecessary delete statement in function
 * @description This query identifies unnecessary 'delete' statements that remove local variables.
 *              Such deletions are redundant because local variables are automatically cleaned up
 *              when the function scope exits. The query excludes cases where deletion might be
 *              necessary, such as within loops or when dealing with sys.exc_info() calls.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/unnecessary-delete
 */

import python

// Predicate to determine if an AST node is inside a loop structure
predicate isWithinLoopContext(AstNode astNode) {
  // Check if the node is directly inside a while or for loop
  astNode.getParentNode() instanceof While
  or
  astNode.getParentNode() instanceof For
  // Check if the node is nested inside another node that is within a loop
  or
  exists(AstNode predecessorNode | 
    isWithinLoopContext(predecessorNode) and 
    astNode = predecessorNode.getAChildNode()
  )
}

// Main query to identify unnecessary delete statements
from Delete deleteStmt, Expr targetExpr, Function containingFunction
where
  // Position check: The delete statement is the last statement in the function
  containingFunction.getLastStatement() = deleteStmt and
  // Target check: The target expression is being deleted
  targetExpr = deleteStmt.getATarget() and
  // Scope check: The target is in the function's scope
  containingFunction.containsInScope(targetExpr) and
  // Type exclusions: Exclude certain types of deletions that might be necessary
  not targetExpr instanceof Subscript and  // e.g., del list[index]
  not targetExpr instanceof Attribute and  // e.g., del obj.attribute
  // Context exclusions: Exclude deletions in certain contexts
  not isWithinLoopContext(deleteStmt) and  // Exclude deletions within loops
  // Special case: Exclude functions that call sys.exc_info() (which may need explicit deletion)
  not exists(FunctionValue excInfoFunc |
    excInfoFunc = Value::named("sys.exc_info") and
    excInfoFunc.getACall().getScope() = containingFunction
  )
select deleteStmt, "Unnecessary deletion of local variable $@ in function $@.", 
  targetExpr, targetExpr.toString(), containingFunction, containingFunction.getName()