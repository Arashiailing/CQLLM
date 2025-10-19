/**
 * @name Unnecessary delete statement in function
 * @description Detects redundant 'delete' statements for local variables,
 *              as variables are automatically cleaned up when function exits.
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
 * Checks if an AST node is nested within any loop structure.
 * Recursively examines parent nodes to determine loop containment.
 */
predicate isWithinLoop(AstNode astNode) {
  // Direct loop parent check
  astNode.getParentNode() instanceof While
  or
  astNode.getParentNode() instanceof For
  or
  // Nested containment through parent chain
  exists(AstNode loopContainer | 
    isWithinLoop(loopContainer) and 
    astNode = loopContainer.getAChildNode()
  )
}

// Identify redundant delete operations in functions
from Delete deletionStmt, Expr deletedExpr, Function enclosingFunc
where
  // Position verification: Last statement in function
  enclosingFunc.getLastStatement() = deletionStmt
  and
  // Target verification: Expression being deleted
  deletedExpr = deletionStmt.getATarget()
  and
  // Scope verification: Target within function scope
  enclosingFunc.containsInScope(deletedExpr)
  and
  // Exclusion 1: Not subscript access (e.g., list[0])
  not deletedExpr instanceof Subscript
  and
  // Exclusion 2: Not attribute access (e.g., obj.attr)
  not deletedExpr instanceof Attribute
  and
  // Loop exclusion: Not within any loop structure
  not isWithinLoop(deletionStmt)
  and
  // Exception handling exclusion: No sys.exc_info() calls
  not exists(FunctionValue excInfoCall |
    excInfoCall = Value::named("sys.exc_info") and
    excInfoCall.getACall().getScope() = enclosingFunc
  )
select deletionStmt, "Unnecessary deletion of local variable $@ in function $@.", deletedExpr, deletedExpr.toString(), enclosingFunc,
  enclosingFunc.getName()