/**
 * @name Unnecessary delete statement in function
 * @description Detects redundant 'delete' operations on local variables that
 *              are automatically garbage collected when the function exits.
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
 * Determines if a given AST node is contained within any loop structure.
 * This predicate checks both direct containment within loops and nested
 * containment by recursively examining parent nodes.
 * 
 * @param examinedNode The AST node to check for loop containment.
 */
predicate isNestedInLoop(AstNode examinedNode) {
  // Check if the immediate parent is a loop construct
  examinedNode.getParentNode() instanceof While
  or
  examinedNode.getParentNode() instanceof For
  or
  // Recursive check for nested containment
  exists(AstNode parentLoopNode | 
    isNestedInLoop(parentLoopNode) and 
    examinedNode = parentLoopNode.getAChildNode()
  )
}

/**
 * Main detection logic for identifying unnecessary delete statements.
 * This query focuses on delete operations that occur at the end of functions
 * and serve no practical purpose due to automatic cleanup mechanisms.
 */
from Delete deleteStmt, Expr deletedVar, Function containingFunction
where
  // Verify the delete statement is the final statement in the function
  containingFunction.getLastStatement() = deleteStmt
  and
  // Extract and validate the expression being deleted
  deletedVar = deleteStmt.getATarget()
  and
  // Ensure the expression is within the function's scope
  containingFunction.containsInScope(deletedVar)
  and
  // Exclude complex deletion operations that modify objects
  not deletedVar instanceof Subscript
  and
  not deletedVar instanceof Attribute
  and
  // Exclude deletes within loops which might be intentional
  not isNestedInLoop(deleteStmt)
  and
  // Exclude functions that call sys.exc_info requiring explicit cleanup
  not exists(FunctionValue sysExcInfoFunction |
    sysExcInfoFunction = Value::named("sys.exc_info") and
    sysExcInfoFunction.getACall().getScope() = containingFunction
  )
select deleteStmt, "Unnecessary deletion of local variable $@ in function $@.", deletedVar, deletedVar.toString(), containingFunction,
  containingFunction.getName()