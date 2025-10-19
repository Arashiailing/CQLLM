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
 * Determines whether the specified AST node is located within a loop structure.
 * Loop structures include 'while' and 'for' loops. This predicate checks both
 * direct containment within a loop and nested containment through recursive
 * parent traversal.
 */
predicate isWithinLoop(AstNode node) {
  // Direct case: the immediate parent is a loop statement
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  or
  // Recursive case: an ancestor is within a loop and the current node is its descendant
  exists(AstNode ancestorInLoop | 
    isWithinLoop(ancestorInLoop) and 
    node = ancestorInLoop.getAChildNode()
  )
}

// Identify unnecessary delete statements in functions
from Delete deletionStatement, Expr deletedExpression, Function enclosingFunction
where
  // Condition 1: The delete statement is the final statement in the function
  enclosingFunction.getLastStatement() = deletionStatement and
  
  // Condition 2: The delete statement targets a specific expression
  deletedExpression = deletionStatement.getATarget() and
  
  // Condition 3: The target expression is within the function's scope
  enclosingFunction.containsInScope(deletedExpression) and
  
  // Condition 4: Exclude deletion of dictionary/list elements (e.g., del a[0])
  not deletedExpression instanceof Subscript and
  
  // Condition 5: Exclude deletion of object attributes (e.g., del a.b)
  not deletedExpression instanceof Attribute and
  
  // Condition 6: Exclude delete statements within loops
  not isWithinLoop(deletionStatement) and
  
  // Condition 7: Exclude cases where sys.exc_info is called, as explicit deletion
  // may be needed to break reference cycles
  not exists(FunctionValue sysExcInfoCall |
    sysExcInfoCall = Value::named("sys.exc_info") and
    sysExcInfoCall.getACall().getScope() = enclosingFunction
  )
select deletionStatement, "Unnecessary deletion of local variable $@ in function $@.", deletedExpression, deletedExpression.toString(), enclosingFunction,
  enclosingFunction.getName()