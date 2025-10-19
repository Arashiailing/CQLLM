/**
 * @name Redundant variable deletion in function
 * @description Deleting a local variable with 'delete' is redundant
 *              since local variables are automatically garbage collected
 *              when the function execution completes.
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
 * Determines if a given AST node is located within a loop structure.
 * Loop structures include 'while' and 'for' loops.
 */
predicate isContainedWithinLoop(AstNode astNode) {
  // Direct parent is a loop type
  astNode.getParentNode() instanceof While
  or
  astNode.getParentNode() instanceof For
  or
  // Recursive check: if there exists a parent node in a loop, and the current node is its child
  exists(AstNode loopParentNode | 
    isContainedWithinLoop(loopParentNode) and 
    astNode = loopParentNode.getAChildNode()
  )
}

// Identify unnecessary deletion statements
from Delete deleteStmt, Expr targetExpr, Function containerFunction
where
  // Check if the deletion statement is the final statement in the function
  containerFunction.getLastStatement() = deleteStmt and
  // Verify the deletion targets a local variable within the function's scope
  targetExpr = deleteStmt.getATarget() and
  containerFunction.containsInScope(targetExpr) and
  // Exclude compound expressions (e.g., del a[0], del a.b)
  not (targetExpr instanceof Subscript or targetExpr instanceof Attribute) and
  // Exclude deletion statements within loops
  not isContainedWithinLoop(deleteStmt) and
  // Exclude functions that call sys.exc_info, which require explicit deletion to break reference cycles
  not exists(FunctionValue sysExcInfoFunc |
    sysExcInfoFunc = Value::named("sys.exc_info") and
    sysExcInfoFunc.getACall().getScope() = containerFunction
  )
select deleteStmt, "Unnecessary deletion of local variable $@ in function $@.", targetExpr, targetExpr.toString(), containerFunction,
  containerFunction.getName()