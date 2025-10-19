/**
 * @name Unnecessary delete statement in function
 * @description Detects unnecessary 'delete' statements targeting local variables
 *              at function exits. Local variables are automatically deleted
 *              when the function scope ends, making explicit deletion redundant.
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
 * Determines whether a given AST node is contained within any loop structure.
 * Recursively checks parent nodes to identify containment in While/For loops.
 */
predicate isContainedWithinLoop(AstNode n) {
  // Direct parent is a loop statement
  n.getParentNode() instanceof While
  or
  n.getParentNode() instanceof For
  or
  // Recursive check: any ancestor node is within a loop
  exists(AstNode parent | isContainedWithinLoop(parent) | n = parent.getAChildNode())
}

from Delete deleteStmt, Expr targetExpr, Function enclosingFunc
where
  // Verify the delete statement is the final statement in the function
  enclosingFunc.getLastStatement() = deleteStmt
  and
  // Ensure the delete target is a local variable (not subscript/attribute access)
  targetExpr = deleteStmt.getATarget()
  and
  enclosingFunc.containsInScope(targetExpr)
  and
  not targetExpr instanceof Subscript
  and
  not targetExpr instanceof Attribute
  and
  // Exclude deletes within loops (potential control flow implications)
  not isContainedWithinLoop(deleteStmt)
  and
  // Exclude functions calling sys.exc_info (requires explicit cleanup)
  not exists(FunctionValue sysExcInfoCall |
    sysExcInfoCall = Value::named("sys.exc_info") and
    sysExcInfoCall.getACall().getScope() = enclosingFunc
  )
select deleteStmt, "Unnecessary deletion of local variable $@ in function $@.", 
  targetExpr, targetExpr.toString(), enclosingFunc, enclosingFunc.getName()