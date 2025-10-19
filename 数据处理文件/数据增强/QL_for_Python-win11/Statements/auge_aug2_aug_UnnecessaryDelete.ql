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

// Determines if a given node is nested within any loop construct (For or While)
predicate isInsideLoop(AstNode nodeToCheck) {
  // Check if the node's parent is a loop
  nodeToCheck.getParentNode() instanceof While
  or
  nodeToCheck.getParentNode() instanceof For
  // Recursively check if any ancestor is inside a loop
  or
  exists(AstNode ancestorInLoop | 
    isInsideLoop(ancestorInLoop) and 
    nodeToCheck = ancestorInLoop.getAChildNode()
  )
}

// Query to find unnecessary delete statements at the end of functions
from Delete deleteStmt, Expr targetVar, Function funcContext
where
  // The delete statement must be the final statement in the function
  funcContext.getLastStatement() = deleteStmt and
  // Identify the variable being deleted
  targetVar = deleteStmt.getATarget() and
  // Ensure the variable is within the function's scope
  funcContext.containsInScope(targetVar) and
  // Exclude complex deletion operations
  (
    // Not a subscript operation (e.g., del list[0])
    not targetVar instanceof Subscript and
    // Not an attribute access (e.g., del obj.attr)
    not targetVar instanceof Attribute
  ) and
  // Exclude deletes within loop constructs
  not isInsideLoop(deleteStmt) and
  // Exclude functions that call sys.exc_info which may require explicit cleanup
  not exists(FunctionValue sysExcInfoFunc |
    sysExcInfoFunc = Value::named("sys.exc_info") and
    sysExcInfoFunc.getACall().getScope() = funcContext
  )
select deleteStmt, "Unnecessary deletion of local variable $@ in function $@.", 
  targetVar, targetVar.toString(), funcContext,
  funcContext.getName()