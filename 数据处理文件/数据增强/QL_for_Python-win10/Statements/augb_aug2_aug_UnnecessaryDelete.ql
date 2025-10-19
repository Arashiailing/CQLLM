/**
 * @name Unnecessary delete statement in function
 * @description Identifies redundant 'delete' operations on local variables that
 *              are automatically cleaned up when the function terminates.
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
 * Determines if a node is nested within any loop structure.
 * This predicate checks recursively to handle nested loops.
 */
predicate isInsideLoop(AstNode node) {
  // Check if the node is a direct child of a loop
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  or
  // Check if the node is a descendant of a node already inside a loop
  exists(AstNode ancestorInLoop | 
    isInsideLoop(ancestorInLoop) and 
    node = ancestorInLoop.getAChildNode()
  )
}

// Main query to identify unnecessary delete statements at function end
from Delete deleteStmt, Expr targetExpr, Function func
where
  // Position conditions: delete must be the final statement in the function
  func.getLastStatement() = deleteStmt and
  
  // Target conditions: must be deleting a variable in the function's scope
  targetExpr = deleteStmt.getATarget() and
  func.containsInScope(targetExpr) and
  
  // Exclusion conditions: not deleting complex expressions
  not targetExpr instanceof Subscript and  // e.g., del list[0]
  not targetExpr instanceof Attribute and  // e.g., del obj.attr
  
  // Context conditions: not inside a loop
  not isInsideLoop(deleteStmt) and
  
  // Special case: functions calling sys.exc_info may need explicit cleanup
  not exists(FunctionValue sysExcInfoFunc |
    sysExcInfoFunc = Value::named("sys.exc_info") and
    sysExcInfoFunc.getACall().getScope() = func
  )
select deleteStmt, "Unnecessary deletion of local variable $@ in function $@.", 
  targetExpr, targetExpr.toString(), func, func.getName()