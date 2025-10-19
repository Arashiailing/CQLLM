/**
 * @name Unnecessary delete statement in function
 * @description Detects redundant 'delete' statements for local variables that
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
 * Determines if an AST node is nested within any loop construct.
 * Recursively checks parent nodes for While/For loops or nested loop contexts.
 */
predicate isInsideLoop(AstNode n) {
  // Direct parent is a loop structure
  n.getParentNode() instanceof While
  or
  n.getParentNode() instanceof For
  or
  // Node is contained within another loop-nested structure
  exists(AstNode parentInLoop | 
    isInsideLoop(parentInLoop) and 
    n = parentInLoop.getAChildNode()
  )
}

// Identify redundant delete statements in function contexts
from Delete delStmt, Expr targetExpr, Function enclosingFunc
where
  // Core condition: delete is function's final statement
  enclosingFunc.getLastStatement() = delStmt and
  
  // Establish delete-target relationship
  targetExpr = delStmt.getATarget() and
  
  // Verify target is function-scoped variable
  enclosingFunc.containsInScope(targetExpr) and
  
  // Exclude complex deletion targets (subscripts/attributes)
  not (
    targetExpr instanceof Subscript or
    targetExpr instanceof Attribute
  ) and
  
  // Exclude deletes within loop constructs
  not isInsideLoop(delStmt) and
  
  // Avoid functions calling sys.exc_info
  not exists(FunctionValue sysExcInfoFunc |
    sysExcInfoFunc = Value::named("sys.exc_info") and
    sysExcInfoFunc.getACall().getScope() = enclosingFunc
  )
select delStmt, "Unnecessary deletion of local variable $@ in function $@.", targetExpr, targetExpr.toString(), enclosingFunc,
  enclosingFunc.getName()