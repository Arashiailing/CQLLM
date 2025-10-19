/**
 * @name Unnecessary delete statement in function
 * @description Identifies redundant 'delete' operations on local variables that
 *              are automatically cleaned up when the function exits, making
 *              the delete statement unnecessary.
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
 * Determines if a node is nested within any loop structure (For or While).
 * This predicate checks both direct nesting within a loop and indirect nesting
 * through parent nodes that are themselves inside loops.
 */
predicate isInsideLoop(AstNode node) {
  // Case 1: Direct child of a loop construct
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  or
  // Case 2: Descendant of a node already inside a loop
  exists(AstNode ancestor | 
    isInsideLoop(ancestor) and 
    node = ancestor.getAChildNode()
  )
}

// Query to identify unnecessary delete statements at the end of functions
from Delete deleteStmt, Expr deletedExpr, Function func
where
  // Position condition: Delete must be the final statement in the function
  func.getLastStatement() = deleteStmt and
  // Target condition: Identify the expression being deleted
  deletedExpr = deleteStmt.getATarget() and
  // Scope condition: Ensure the expression is within the function's scope
  func.containsInScope(deletedExpr) and
  // Exclusion conditions: Skip certain types of delete operations
  (
    // Exclude subscript operations (e.g., del list[0])
    not deletedExpr instanceof Subscript
    and
    // Exclude attribute access (e.g., del obj.attr)
    not deletedExpr instanceof Attribute
  ) and
  // Context condition: Exclude deletes within loop constructs
  not isInsideLoop(deleteStmt) and
  // Special case condition: Exclude functions calling sys.exc_info which may need explicit cleanup
  not exists(FunctionValue sysExcInfo |
    sysExcInfo = Value::named("sys.exc_info") and
    sysExcInfo.getACall().getScope() = func
  )
select deleteStmt, "Unnecessary deletion of local variable $@ in function $@.", 
  deletedExpr, deletedExpr.toString(), func, func.getName()