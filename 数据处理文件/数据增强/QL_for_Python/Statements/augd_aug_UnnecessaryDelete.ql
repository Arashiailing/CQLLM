/**
 * @name Unnecessary delete statement in function
 * @description Identifies redundant 'delete' operations on local variables that
 *              are automatically cleaned up when the function terminates.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/unnecessary-delete
 */

import python

// Determines if an AST node is contained within any loop structure (While or For)
// This check is performed recursively to handle nested loops
predicate isInsideLoop(AstNode astNode) {
  // Case 1: Node is a direct child of a While loop
  astNode.getParentNode() instanceof While
  or
  // Case 2: Node is a direct child of a For loop
  astNode.getParentNode() instanceof For
  or
  // Case 3: Node is a descendant of another node already inside a loop
  exists(AstNode parentInLoop | isInsideLoop(parentInLoop) | astNode = parentInLoop.getAChildNode())
}

// Main query to identify unnecessary delete statements at the end of functions
from Delete delOperation, Expr deletedVar, Function containingFunction
where
  // Position verification: Ensure the delete operation is the final statement
  containingFunction.getLastStatement() = delOperation and
  
  // Target identification: Get the expression being deleted
  deletedVar = delOperation.getATarget() and
  
  // Scope validation: Confirm the deleted variable is within the function's scope
  containingFunction.containsInScope(deletedVar) and
  
  // Exclusion criteria: Skip certain types of delete operations
  // Exclude subscript operations (e.g., del list[0])
  not deletedVar instanceof Subscript and
  // Exclude attribute access (e.g., del obj.attr)
  not deletedVar instanceof Attribute and
  // Exclude delete operations inside loops
  not isInsideLoop(delOperation) and
  
  // Special case handling: Skip functions that call sys.exc_info
  // Such functions may require explicit cleanup of exception information
  not exists(FunctionValue sysExcInfoCall |
    sysExcInfoCall = Value::named("sys.exc_info") and
    sysExcInfoCall.getACall().getScope() = containingFunction
  )
select delOperation, "Unnecessary deletion of local variable $@ in function $@.", deletedVar, deletedVar.toString(), containingFunction,
  containingFunction.getName()