/**
 * @name Redundant local variable deletion in functions
 * @description Detects 'delete' operations that remove local variables unnecessarily.
 *              These operations are superfluous since local variables are automatically
 *              garbage collected when function execution completes. The query filters out
 *              scenarios where deletion might be required, such as loop contexts or
 *              functions utilizing sys.exc_info().
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/unnecessary-delete
 */

import python

// Helper predicate that determines whether an AST node is located within any loop construct
predicate isInsideLoopStructure(AstNode node) {
  // Direct containment within a loop statement
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  // Indirect containment through nested structures
  or
  exists(AstNode parentInLoop | 
    isInsideLoopStructure(parentInLoop) and 
    node = parentInLoop.getAChildNode()
  )
}

// Query to identify superfluous delete operations on local variables
from Delete deletionOp, Expr deletedVar, Function enclosingFunction
where
  // Position validation: deletion occurs as the final statement in the function
  enclosingFunction.getLastStatement() = deletionOp and
  // Target identification: the expression being deleted
  deletedVar = deletionOp.getATarget() and
  // Scope verification: target is within the function's scope
  enclosingFunction.containsInScope(deletedVar) and
  // Context validation: not within loop structures
  not isInsideLoopStructure(deletionOp) and
  // Type exclusions: avoid complex deletion targets that might be intentional
  not deletedVar instanceof Subscript and  // e.g., del list[index]
  not deletedVar instanceof Attribute and  // e.g., del obj.attribute
  // Special case handling: exclude functions that utilize sys.exc_info()
  not exists(FunctionValue sysExcInfoCall |
    sysExcInfoCall = Value::named("sys.exc_info") and
    sysExcInfoCall.getACall().getScope() = enclosingFunction
  )
select deletionOp, "Superfluous deletion of local variable $@ in function $@.", 
  deletedVar, deletedVar.toString(), enclosingFunction, enclosingFunction.getName()