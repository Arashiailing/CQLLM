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

// Recursively determines if a node is contained within any loop structure
predicate isNestedInLoop(AstNode node) {
  // Node is a direct child of a While or For loop
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  // Node is a descendant of another node already inside a loop
  or
  exists(AstNode ancestor | 
    isNestedInLoop(ancestor) and 
    node = ancestor.getAChildNode()
  )
}

// Query for detecting unnecessary delete statements at function end
from Delete delStmt, Expr varExpr, Function func
where
  // The delete is the final statement in the function
  func.getLastStatement() = delStmt and
  // Get the expression being deleted
  varExpr = delStmt.getATarget() and
  // The expression is within the function's scope
  func.containsInScope(varExpr) and
  // Exclude subscript operations (e.g., del list[0])
  not varExpr instanceof Subscript and
  // Exclude attribute access (e.g., del obj.attr)
  not varExpr instanceof Attribute and
  // Exclude deletes within loop constructs
  not isNestedInLoop(delStmt) and
  // Exclude functions calling sys.exc_info which may need explicit cleanup
  not exists(FunctionValue excInfoCall |
    excInfoCall = Value::named("sys.exc_info") and
    excInfoCall.getACall().getScope() = func
  )
select delStmt, "Unnecessary deletion of local variable $@ in function $@.", 
  varExpr, varExpr.toString(), func, func.getName()