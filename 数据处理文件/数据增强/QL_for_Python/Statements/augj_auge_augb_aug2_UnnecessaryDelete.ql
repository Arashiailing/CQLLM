/**
 * @name Unnecessary delete statement in function
 * @description Detects redundant 'delete' statements for local variables.
 *              Such deletions are unnecessary since variables are automatically
 *              garbage-collected when function execution completes.
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
 * Recursively checks if an AST node is nested within any loop structure.
 * Handles both direct loop nesting and transitive containment through parent nodes.
 */
predicate isInsideLoop(AstNode n) {
  // Direct parent is a loop construct
  n.getParentNode() instanceof While
  or
  n.getParentNode() instanceof For
  or
  // Transitive containment through parent nodes
  exists(AstNode parentInLoop | 
    isInsideLoop(parentInLoop) and 
    n = parentInLoop.getAChildNode()
  )
}

// Identify superfluous variable deletions in function contexts
from Delete delStmt, Expr deletedVar, Function enclosingFunc
where
  // Positional requirement: deletion must be final function statement
  enclosingFunc.getLastStatement() = delStmt and
  
  // Target validation: must be a simple variable deletion
  deletedVar = delStmt.getATarget() and
  not (
    deletedVar instanceof Subscript or
    deletedVar instanceof Attribute
  ) and
  
  // Scope verification: variable must be function-local
  enclosingFunc.containsInScope(deletedVar) and
  
  // Contextual exclusions:
  // 1. Not within loop structures
  not isInsideLoop(delStmt) and
  // 2. Not in functions using exception state
  not exists(FunctionValue excInfoFunc |
    excInfoFunc = Value::named("sys.exc_info") and
    excInfoFunc.getACall().getScope() = enclosingFunc
  )
select delStmt, "Unnecessary deletion of local variable $@ in function $@.", deletedVar, deletedVar.toString(), enclosingFunc,
  enclosingFunc.getName()