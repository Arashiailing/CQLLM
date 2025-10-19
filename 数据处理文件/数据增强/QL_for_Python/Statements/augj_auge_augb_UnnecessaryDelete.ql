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
 * Checks if an AST node is nested inside any loop structure.
 * This predicate identifies nodes within 'for' or 'while' loops,
 * including deeply nested cases through recursive parent traversal.
 */
predicate isWithinLoop(AstNode node) {
  // Base case: direct child of a loop statement
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  or
  // Recursive case: nested within a loop through ancestor nodes
  exists(AstNode loopAncestor | 
    isWithinLoop(loopAncestor) and 
    node = loopAncestor.getAChildNode()
  )
}

// Detect unnecessary delete statements that remove local variables
from Delete delStmt, Expr targetExpr, Function containerFunc
where
  // Positional conditions: delete must be the final statement in the function
  containerFunc.getLastStatement() = delStmt and
  
  // Target expression conditions: must be a valid local variable deletion
  targetExpr = delStmt.getATarget() and
  containerFunc.containsInScope(targetExpr) and
  
  // Exclusion conditions: skip certain deletion patterns
  not targetExpr instanceof Subscript and  // Not deleting collection elements
  not targetExpr instanceof Attribute and  // Not deleting object attributes
  not isWithinLoop(delStmt) and            // Not inside a loop
  
  // Special case: preserve deletes when sys.exc_info is used in the function
  not exists(FunctionValue excInfoCall |
    excInfoCall = Value::named("sys.exc_info") and
    excInfoCall.getACall().getScope() = containerFunc
  )
select delStmt, "Unnecessary deletion of local variable $@ in function $@.", targetExpr, targetExpr.toString(), containerFunc,
  containerFunc.getName()