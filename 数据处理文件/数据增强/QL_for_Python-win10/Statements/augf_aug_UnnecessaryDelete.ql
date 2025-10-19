/**
 * @name Unnecessary delete statement in function
 * @description Identifies redundant 'delete' operations on local variables
 *              that are automatically cleaned up when the function exits.
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
predicate isInsideLoop(AstNode currentNode) {
  // Case 1: Direct child of a While or For loop
  currentNode.getParentNode() instanceof While
  or
  currentNode.getParentNode() instanceof For
  // Case 2: Descendant of a node already inside a loop
  or
  exists(AstNode parentInLoop | 
    isInsideLoop(parentInLoop) and 
    currentNode = parentInLoop.getAChildNode()
  )
}

// Query to detect unnecessary delete statements at function termination
from Delete delStatement, Expr deletedExpr, Function enclosingFunc
where
  // Position verification: delete is the final statement in the function
  enclosingFunc.getLastStatement() = delStatement and
  // Target identification: expression being deleted
  deletedExpr = delStatement.getATarget() and
  // Scope validation: expression is within function's scope
  enclosingFunc.containsInScope(deletedExpr) and
  // Exclusion 1: Skip subscript operations (e.g., del list[0])
  not deletedExpr instanceof Subscript and
  // Exclusion 2: Skip attribute access (e.g., del obj.attr)
  not deletedExpr instanceof Attribute and
  // Exclusion 3: Skip deletes within loop constructs
  not isInsideLoop(delStatement) and
  // Exclusion 4: Skip functions calling sys.exc_info (may need cleanup)
  not exists(FunctionValue excInfoCall |
    excInfoCall = Value::named("sys.exc_info") and
    excInfoCall.getACall().getScope() = enclosingFunc
  )
select delStatement, 
  "Unnecessary deletion of local variable $@ in function $@.", 
  deletedExpr, deletedExpr.toString(), 
  enclosingFunc, enclosingFunc.getName()