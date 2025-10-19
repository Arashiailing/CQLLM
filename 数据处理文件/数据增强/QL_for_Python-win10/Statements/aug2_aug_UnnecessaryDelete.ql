/**
 * @name Unnecessary delete statement in function
 * @description Detects redundant 'delete' operations on local variables that
 *              would be automatically cleaned up when the function terminates.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/unnecessary-delete
 */

import python

// Recursively determines if a node is nested within any loop structure
predicate isInsideLoop(AstNode currentNode) {
  // Direct child of a While or For loop
  currentNode.getParentNode() instanceof While
  or
  currentNode.getParentNode() instanceof For
  // Descendant of a node already inside a loop
  or
  exists(AstNode loopAncestor | 
    isInsideLoop(loopAncestor) and 
    currentNode = loopAncestor.getAChildNode()
  )
}

// Query for identifying unnecessary delete statements at function end
from Delete deleteOperation, Expr deletedVariable, Function containingFunction
where
  // Verify the delete is the final statement in the function
  containingFunction.getLastStatement() = deleteOperation and
  // Identify the expression being deleted
  deletedVariable = deleteOperation.getATarget() and
  // Ensure the expression is within the function's scope
  containingFunction.containsInScope(deletedVariable) and
  // Exclude subscript operations (e.g., del list[0])
  not deletedVariable instanceof Subscript and
  // Exclude attribute access (e.g., del obj.attr)
  not deletedVariable instanceof Attribute and
  // Exclude deletes within loop constructs
  not isInsideLoop(deleteOperation) and
  // Exclude functions calling sys.exc_info which may need explicit cleanup
  not exists(FunctionValue sysExcInfoCall |
    sysExcInfoCall = Value::named("sys.exc_info") and
    sysExcInfoCall.getACall().getScope() = containingFunction
  )
select deleteOperation, "Unnecessary deletion of local variable $@ in function $@.", 
  deletedVariable, deletedVariable.toString(), containingFunction,
  containingFunction.getName()