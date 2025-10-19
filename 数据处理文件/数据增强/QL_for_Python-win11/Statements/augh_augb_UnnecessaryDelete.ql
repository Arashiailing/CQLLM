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
 * Determines if a given AST node is located within a loop structure.
 * Loop structures include 'while' and 'for' loops.
 */
predicate locatedInLoop(AstNode node) {
  // Direct parent is a loop type
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  or
  // Recursive check: if there exists a parent node in a loop, and the current node is its child
  exists(AstNode loopAncestor | 
    locatedInLoop(loopAncestor) and 
    node = loopAncestor.getAChildNode()
  )
}

// Identify unnecessary deletion statements
from Delete deletionStatement, Expr deletedExpression, Function enclosingFunction
where
  // The deletion statement is the final statement in the function
  enclosingFunction.getLastStatement() = deletionStatement and
  // The deletion statement targets a local variable within the function's scope
  deletedExpression = deletionStatement.getATarget() and
  enclosingFunction.containsInScope(deletedExpression) and
  // Exclude deletion of compound expressions (e.g., del a[0], del a.b)
  not (deletedExpression instanceof Subscript or deletedExpression instanceof Attribute) and
  // Exclude deletion statements within loops
  not locatedInLoop(deletionStatement) and
  // Exclude functions that call sys.exc_info, which require explicit deletion to break reference cycles
  not exists(FunctionValue excInfoFunction |
    excInfoFunction = Value::named("sys.exc_info") and
    excInfoFunction.getACall().getScope() = enclosingFunction
  )
select deletionStatement, "Unnecessary deletion of local variable $@ in function $@.", deletedExpression, deletedExpression.toString(), enclosingFunction,
  enclosingFunction.getName()