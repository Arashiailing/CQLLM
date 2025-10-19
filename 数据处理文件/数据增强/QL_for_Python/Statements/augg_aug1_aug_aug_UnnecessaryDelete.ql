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
 * Determines if an AST node is contained within any loop structure (For or While).
 * This predicate recursively checks whether a node resides inside loop constructs,
 * which is crucial for identifying delete statements that might be needed across
 * multiple iterations.
 * 
 * @param node The AST node to examine for loop containment.
 */
predicate isNestedInLoop(AstNode node) {
  // Recursive case: Node is a descendant of another node already identified in a loop
  exists(AstNode ancestorInLoop | 
    isNestedInLoop(ancestorInLoop) and 
    node = ancestorInLoop.getAChildNode()
  )
  or
  // Base case: Node is a direct child of a loop statement
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
}

/**
 * Main query to detect unnecessary delete statements at function termination.
 * These operations are redundant because local variables are automatically
 * cleaned up when the function exits. The query excludes cases where deletion
 * might be necessary, such as within loops or when handling system calls.
 */
from Delete delStmt, Expr deletedExpr, Function enclosingFunc
where
  // Verify the delete statement is the final statement in the function
  enclosingFunc.getLastStatement() = delStmt
  and
  // Confirm the deleted expression is within the function's scope
  enclosingFunc.containsInScope(deletedExpr)
  and
  // Identify the expression being deleted
  deletedExpr = delStmt.getATarget()
  and
  // Exclude subscript operations (e.g., del list[0]) as they modify objects
  not deletedExpr instanceof Subscript
  and
  // Exclude attribute access (e.g., del obj.attr) as they alter object state
  not deletedExpr instanceof Attribute
  and
  // Exclude deletes within loop constructs that might be needed for iterations
  not isNestedInLoop(delStmt)
  and
  // Exclude functions with sys.exc_info calls requiring explicit cleanup
  not exists(FunctionValue sysExcInfoCall |
    sysExcInfoCall = Value::named("sys.exc_info") and
    sysExcInfoCall.getACall().getScope() = enclosingFunc
  )
select delStmt, "Unnecessary deletion of local variable $@ in function $@.", deletedExpr, deletedExpr.toString(), enclosingFunc, enclosingFunc.getName()