/**
 * @name Unnecessary delete statement in function
 * @description Detects redundant 'delete' statements for local variables,
 *              as they are automatically cleaned up when the function exits.
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
 * Determines if a node is nested inside any loop structure.
 * Covers both 'while' and 'for' loop constructs.
 */
predicate isInsideLoop(AstNode node) {
  // Direct parent is a loop type
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  or
  // Recursive check: node has a parent inside a loop
  exists(AstNode loopParent | 
    isInsideLoop(loopParent) and 
    node = loopParent.getAChildNode()
  )
}

// Identify redundant delete operations
from Delete unnecessaryDelete, Expr deletedTarget, Function enclosingFunction
where
  // Condition 1: Delete is the final statement in the function
  enclosingFunction.getLastStatement() = unnecessaryDelete and
  // Condition 2: Target expression matches the delete operand
  deletedTarget = unnecessaryDelete.getATarget() and
  // Condition 3: Target is within function's scope
  enclosingFunction.containsInScope(deletedTarget) and
  // Condition 4: Exclude subscript deletions (e.g., del a[0])
  not deletedTarget instanceof Subscript and
  // Condition 5: Exclude attribute deletions (e.g., del a.b)
  not deletedTarget instanceof Attribute and
  // Condition 6: Exclude deletes inside loops
  not isInsideLoop(unnecessaryDelete) and
  // Condition 7: Exclude functions using sys.exc_info (requires explicit cleanup)
  not exists(FunctionValue excInfoCall |
    excInfoCall = Value::named("sys.exc_info") and
    excInfoCall.getACall().getScope() = enclosingFunction
  )
select unnecessaryDelete, "Unnecessary deletion of local variable $@ in function $@.", deletedTarget, deletedTarget.toString(), enclosingFunction,
  enclosingFunction.getName()