/**
 * @name Unnecessary delete statement in function
 * @description Detects redundant 'delete' operations on local variables that
 *              would be automatically cleaned up when the function terminates.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/unnecessary-delete
 */

import python

// Recursively checks if a node is nested within any loop structure
predicate isInsideLoop(AstNode node) {
  // Direct child of a While or For loop
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  // Descendant of a node already inside a loop
  or
  exists(AstNode ancestorNode | isInsideLoop(ancestorNode) | node = ancestorNode.getAChildNode())
}

// Query for identifying unnecessary delete statements at function end
from Delete deleteStmt, Expr targetExpr, Function targetFunc
where
  // Verify the delete is the final statement in the function
  targetFunc.getLastStatement() = deleteStmt and
  // Identify the expression being deleted
  targetExpr = deleteStmt.getATarget() and
  // Ensure the expression is within the function's scope
  targetFunc.containsInScope(targetExpr) and
  // Exclude subscript operations (e.g., del list[0])
  not targetExpr instanceof Subscript and
  // Exclude attribute access (e.g., del obj.attr)
  not targetExpr instanceof Attribute and
  // Exclude deletes within loop constructs
  not isInsideLoop(deleteStmt) and
  // Exclude functions calling sys.exc_info which may need explicit cleanup
  not exists(FunctionValue excInfoCall |
    excInfoCall = Value::named("sys.exc_info") and
    excInfoCall.getACall().getScope() = targetFunc
  )
select deleteStmt, "Unnecessary deletion of local variable $@ in function $@.", targetExpr, targetExpr.toString(), targetFunc,
  targetFunc.getName()