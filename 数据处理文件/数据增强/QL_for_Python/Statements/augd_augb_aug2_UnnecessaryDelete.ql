/**
 * @name Unnecessary delete statement in function
 * @description Using a 'delete' statement to delete a local variable is
 *              unnecessary, because the variable is deleted automatically when
 *              the function exits.
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
 * Check if the given AST node is inside a loop (while or for).
 * Recursively checks the parent nodes until a loop is found or the root is reached.
 */
predicate isInsideLoop(AstNode node) {
  // Direct parent is a loop
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  or
  // Nested inside another node within a loop
  exists(AstNode loopParent | 
    isInsideLoop(loopParent) and 
    node = loopParent.getAChildNode()
  )
}

// Identify unnecessary delete statements within functions
from Delete deleteStmt, Expr targetExpr, Function func
where
  // Core conditions for unnecessary deletion
  func.getLastStatement() = deleteStmt and
  targetExpr = deleteStmt.getATarget() and
  func.containsInScope(targetExpr) and
  
  // Exclude complex deletion targets (subscripts/attributes)
  not (
    targetExpr instanceof Subscript or
    targetExpr instanceof Attribute
  ) and
  
  // Exclude deletions within loops
  not isInsideLoop(deleteStmt) and
  
  // Exclude functions calling sys.exc_info
  not exists(FunctionValue excInfoCall |
    excInfoCall = Value::named("sys.exc_info") and
    excInfoCall.getACall().getScope() = func
  )
select deleteStmt, "Unnecessary deletion of local variable $@ in function $@.", targetExpr, targetExpr.toString(), func,
  func.getName()