/**
 * @name Unnecessary delete statement in function
 * @description Detects redundant 'delete' statements for local variables,
 *              since they are automatically destroyed when the function exits.
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
 * Recursively determines if an AST node is nested within any loop structure.
 * Checks both direct parent relationships and nested containment within loops.
 */
predicate isInsideLoop(AstNode node) {
  // Direct loop parent check
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  or
  // Nested loop containment check
  exists(AstNode ancestorNode | 
    isInsideLoop(ancestorNode) and 
    node = ancestorNode.getAChildNode()
  )
}

// Identify redundant delete operations in functions
from Delete delStmt, Expr deletedExpr, Function func
where
  // Position constraint: Must be the final statement in function
  func.getLastStatement() = delStmt
  and
  // Target constraint: Must target a specific expression
  deletedExpr = delStmt.getATarget()
  and
  // Scope constraint: Target must be within function's scope
  func.containsInScope(deletedExpr)
  and
  // Exclusion constraints: Target must not be complex access
  not deletedExpr instanceof Subscript
  and
  not deletedExpr instanceof Attribute
  and
  // Context constraint: Must not be inside any loop
  not isInsideLoop(delStmt)
  and
  // Exception safety: No sys.exc_info() calls in function
  not exists(FunctionValue excInfoCall |
    excInfoCall = Value::named("sys.exc_info") and
    excInfoCall.getACall().getScope() = func
  )
select delStmt, "Unnecessary deletion of local variable $@ in function $@.", deletedExpr, deletedExpr.toString(), func,
  func.getName()