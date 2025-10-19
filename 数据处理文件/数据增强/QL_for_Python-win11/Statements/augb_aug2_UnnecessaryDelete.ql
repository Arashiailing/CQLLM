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
 * Recursively checks if the node's parent is a While or For loop, or if the node
 * is a child of another node that is inside a loop.
 */
predicate isInsideLoop(AstNode node) {
  // Base case: the node's direct parent is a loop structure
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  or
  // Recursive case: the node is a child of another node inside a loop
  exists(AstNode loopParent | 
    isInsideLoop(loopParent) and 
    node = loopParent.getAChildNode()
  )
}

// Find unnecessary delete statements in functions
from Delete delStatement, Expr deletedTarget, Function enclosingFunction
where
  // Basic conditions for an unnecessary delete statement
  enclosingFunction.getLastStatement() = delStatement and
  deletedTarget = delStatement.getATarget() and
  enclosingFunction.containsInScope(deletedTarget) and
  
  // Exclude specific types of deletion targets
  not (
    deletedTarget instanceof Subscript or
    deletedTarget instanceof Attribute
  ) and
  
  // Exclude delete statements inside loops
  not isInsideLoop(delStatement) and
  
  // Exclude cases where sys.exc_info is called
  not exists(FunctionValue excInfoFunction |
    excInfoFunction = Value::named("sys.exc_info") and
    excInfoFunction.getACall().getScope() = enclosingFunction
  )
select delStatement, "Unnecessary deletion of local variable $@ in function $@.", deletedTarget, deletedTarget.toString(), enclosingFunction,
  enclosingFunction.getName()