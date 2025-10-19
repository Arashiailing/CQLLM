/**
 * @name Unnecessary delete statement in function
 * @description Identifies redundant 'delete' operations on local variables that
 *              are automatically cleaned up when the function exits.
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
 * Checks if an AST node is located inside any loop structure (For or While).
 * This predicate recursively traverses the AST to determine if a node
 * is contained within loop constructs, which is crucial for identifying
 * cases where delete statements might be needed for multiple iterations.
 * 
 * @param astNode The AST node to be checked for loop containment.
 */
predicate isNestedInLoop(AstNode astNode) {
  // Direct parent is a loop statement
  astNode.getParentNode() instanceof While
  or
  astNode.getParentNode() instanceof For
  // Recursive case: node is a descendant of another node already in a loop
  or
  exists(AstNode loopParent | 
    isNestedInLoop(loopParent) and 
    astNode = loopParent.getAChildNode()
  )
}

/**
 * Main detection logic for unnecessary delete statements at function exit.
 * These operations are redundant because local variables are automatically
 * garbage collected when the function terminates. The query excludes cases
 * where deletion might be intentional (e.g., within loops or when handling
 * system exception information).
 */
from Delete delStmt, Expr deletedExpr, Function func
where
  // Verify the delete statement is the final statement in the function
  func.getLastStatement() = delStmt
  and
  // Extract and validate the expression being deleted
  deletedExpr = delStmt.getATarget()
  and
  // Ensure the expression is within the function's scope
  func.containsInScope(deletedExpr)
  and
  // Exclude complex deletion operations that modify objects
  not deletedExpr instanceof Subscript
  and
  not deletedExpr instanceof Attribute
  and
  // Exclude deletes within loops which might be intentional
  not isNestedInLoop(delStmt)
  and
  // Exclude functions that call sys.exc_info requiring explicit cleanup
  not exists(FunctionValue excInfoCall |
    excInfoCall = Value::named("sys.exc_info") and
    excInfoCall.getACall().getScope() = func
  )
select delStmt, "Unnecessary deletion of local variable $@ in function $@.", deletedExpr, deletedExpr.toString(), func,
  func.getName()