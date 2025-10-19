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

// Identify redundant delete statements within function definitions
from Delete deletionStmt, Expr targetVar, Function containerFunc
where
  // Core condition: delete statement is the final statement in the function
  containerFunc.getLastStatement() = deletionStmt and
  
  // Establish relationship between delete statement and its target
  targetVar = deletionStmt.getATarget() and
  
  // Verify the target variable is within the function's scope
  containerFunc.containsInScope(targetVar) and
  
  // Exclude complex deletion targets (subscripts and attributes)
  not (
    targetVar instanceof Subscript or
    targetVar instanceof Attribute
  ) and
  
  // Exclude delete statements that are within loops
  not isInsideLoop(deletionStmt) and
  
  // Avoid flagging deletes in functions that call sys.exc_info
  not exists(FunctionValue excInfoFunc |
    excInfoFunc = Value::named("sys.exc_info") and
    excInfoFunc.getACall().getScope() = containerFunc
  )
select deletionStmt, "Unnecessary deletion of local variable $@ in function $@.", targetVar, targetVar.toString(), containerFunc,
  containerFunc.getName()