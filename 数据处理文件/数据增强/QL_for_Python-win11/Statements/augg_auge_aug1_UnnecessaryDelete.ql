/**
 * @name Unnecessary delete statement in function
 * @description Detects unnecessary 'delete' operations on local variables. 
 *              These operations are redundant because local variables are automatically
 *              cleaned up when function execution completes. The analysis excludes
 *              cases where deletion might be necessary, such as inside loops
 *              or when dealing with sys.exc_info() exception handling.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/unnecessary-delete
 */

import python

// Determines whether an AST node is positioned inside any loop structure
predicate isWithinLoopContext(AstNode node) {
  // Check for direct containment in loop statements
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  // Recursively check for nested containment
  or
  exists(AstNode parent | 
    isWithinLoopContext(parent) and 
    node = parent.getAChildNode()
  )
}

// Main analysis to identify superfluous variable deletions
from Delete deleteStmt, Expr deletedVar, Function hostFunction
where
  // Condition 1: Deletion is the final statement in the function body
  hostFunction.getLastStatement() = deleteStmt and
  // Condition 2: Identify the expression being deleted
  deletedVar = deleteStmt.getATarget() and
  // Condition 3: Verify variable is in function's scope
  hostFunction.containsInScope(deletedVar) and
  // Condition 4: Exclude complex deletion targets (subscripts and attributes)
  not deletedVar instanceof Subscript and  // e.g., del dict[key]
  not deletedVar instanceof Attribute and  // e.g., del obj.attr
  // Condition 5: Exclude deletions within loop contexts
  not isWithinLoopContext(deleteStmt) and
  // Condition 6: Exclude functions that use sys.exc_info() (requires explicit cleanup)
  not exists(FunctionValue excInfoFunc |
    excInfoFunc = Value::named("sys.exc_info") and
    excInfoFunc.getACall().getScope() = hostFunction
  )
select deleteStmt, "Unnecessary deletion of local variable $@ in function $@.", 
  deletedVar, deletedVar.toString(), hostFunction, hostFunction.getName()