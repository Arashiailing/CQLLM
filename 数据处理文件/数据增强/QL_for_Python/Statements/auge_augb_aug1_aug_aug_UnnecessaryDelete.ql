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
 * @param node The AST node to check for loop containment.
 */
predicate isNestedInLoop(AstNode node) {
  // Check if the immediate parent is a loop construct
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  or
  // Recursive check for nested containment
  exists(AstNode ancestorNode | 
    isNestedInLoop(ancestorNode) and 
    node = ancestorNode.getAChildNode()
  )
}

/**
 * Main detection logic for identifying unnecessary delete statements.
 * This query focuses on delete operations that occur at the end of functions
 * and serve no practical purpose due to automatic cleanup mechanisms.
 */
from Delete deletion, Expr targetExpr, Function function
where
  // Verify the delete statement is the final statement in the function
  function.getLastStatement() = deletion
  and
  // Extract and validate the expression being deleted
  targetExpr = deletion.getATarget()
  and
  // Ensure the expression is within the function's scope
  function.containsInScope(targetExpr)
  and
  // Exclude complex deletion operations that modify objects
  not targetExpr instanceof Subscript
  and
  not targetExpr instanceof Attribute
  and
  // Exclude deletes within loops which might be intentional
  not isNestedInLoop(deletion)
  and
  // Exclude functions that call sys.exc_info requiring explicit cleanup
  not exists(FunctionValue sysExcInfoCall |
    sysExcInfoCall = Value::named("sys.exc_info") and
    sysExcInfoCall.getACall().getScope() = function
  )
select deletion, "Unnecessary deletion of local variable $@ in function $@.", targetExpr, targetExpr.toString(), function,
  function.getName()