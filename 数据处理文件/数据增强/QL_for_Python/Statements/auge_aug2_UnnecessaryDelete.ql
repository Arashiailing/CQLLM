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
 * Recursively checks if the node's parent is a While/For loop or if the node
 * is nested within another node that is inside a loop.
 */
predicate isInsideLoop(AstNode node) {
  // Base case: Direct parent is a loop structure
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  or
  // Recursive case: Node is a child of a loop-enclosed node
  exists(AstNode loopParent | 
    isInsideLoop(loopParent) and 
    node = loopParent.getAChildNode()
  )
}

// Identify unnecessary delete statements within functions
from Delete deleteStatement, Expr target, Function function
where
  // Position condition: Delete is the final statement in the function
  function.getLastStatement() = deleteStatement
  and
  // Target condition: Delete operation targets a specific expression
  target = deleteStatement.getATarget()
  and
  // Scope condition: Target expression is within function's scope
  function.containsInScope(target)
  and
  // Exclusion condition 1: Target is not subscript access (e.g., list[0])
  not target instanceof Subscript
  and
  // Exclusion condition 2: Target is not attribute access (e.g., obj.attr)
  not target instanceof Attribute
  and
  // Loop condition: Delete statement is not inside any loop
  not isInsideLoop(deleteStatement)
  and
  // Exception condition: No sys.exc_info() calls in function context
  not exists(FunctionValue sysExcInfo |
    sysExcInfo = Value::named("sys.exc_info") and
    sysExcInfo.getACall().getScope() = function
  )
select deleteStatement, "Unnecessary deletion of local variable $@ in function $@.", target, target.toString(), function,
  function.getName()