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

// Determines if a node is nested within any loop construct (For/While)
predicate isInLoopContext(AstNode node) {
  // Direct child of a loop statement
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  // Descendant of a node already identified in a loop
  or
  exists(AstNode loopAncestor | 
    isInLoopContext(loopAncestor) and 
    node = loopAncestor.getAChildNode()
  )
}

// Finds unnecessary delete statements at function termination
from Delete delStmt, Expr deletedExpr, Function enclosingFunc
where
  // Confirm delete is the final statement in the function
  enclosingFunc.getLastStatement() = delStmt
  and
  // Identify the expression being deleted
  deletedExpr = delStmt.getATarget()
  and
  // Verify expression is within function scope
  enclosingFunc.containsInScope(deletedExpr)
  and
  // Exclude subscript operations (e.g., del list[0])
  not deletedExpr instanceof Subscript
  and
  // Exclude attribute access (e.g., del obj.attr)
  not deletedExpr instanceof Attribute
  and
  // Exclude deletes within loop constructs
  not isInLoopContext(delStmt)
  and
  // Exclude functions with sys.exc_info calls requiring explicit cleanup
  not exists(FunctionValue sysExcInfoCall |
    sysExcInfoCall = Value::named("sys.exc_info") and
    sysExcInfoCall.getACall().getScope() = enclosingFunc
  )
select delStmt, "Unnecessary deletion of local variable $@ in function $@.", deletedExpr, deletedExpr.toString(), enclosingFunc,
  enclosingFunc.getName()