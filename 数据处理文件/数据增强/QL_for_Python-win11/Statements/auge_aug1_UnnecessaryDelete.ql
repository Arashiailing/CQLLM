/**
 * @name Unnecessary delete statement in function
 * @description Identifies redundant 'delete' operations on local variables. 
 *              These deletions are superfluous since local variables are automatically
 *              garbage collected when function scope terminates. The analysis excludes
 *              scenarios where deletion might be required, such as within iterative
 *              constructs or when handling sys.exc_info() operations.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/unnecessary-delete
 */

import python

// Helper predicate to determine if an AST node resides within loop constructs
predicate isInLoopEnvironment(AstNode node) {
  // Direct containment within loop structures
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  // Nested containment through parent-child relationships
  or
  exists(AstNode parentNode | 
    isInLoopEnvironment(parentNode) and 
    node = parentNode.getAChildNode()
  )
}

// Primary query logic to detect superfluous delete operations
from Delete deletionOperation, Expr variableTarget, Function enclosingFunction
where
  // Positional verification: Deletion occurs as final statement in function
  enclosingFunction.getLastStatement() = deletionOperation and
  // Target verification: Expression being deleted is identified
  variableTarget = deletionOperation.getATarget() and
  // Scope verification: Target variable exists within function's lexical scope
  enclosingFunction.containsInScope(variableTarget) and
  // Exclusion criteria: Skip potentially necessary deletion patterns
  not variableTarget instanceof Subscript and  // e.g., del collection[key]
  not variableTarget instanceof Attribute and  // e.g., del object.property
  // Contextual exclusions: Avoid deletions in specific execution contexts
  not isInLoopEnvironment(deletionOperation) and  // Exclude loop-contained deletions
  // Special case handling: Exclude functions utilizing sys.exc_info() (requiring explicit cleanup)
  not exists(FunctionValue exceptionInfoFunction |
    exceptionInfoFunction = Value::named("sys.exc_info") and
    exceptionInfoFunction.getACall().getScope() = enclosingFunction
  )
select deletionOperation, "Redundant removal of local variable $@ within function $@.", 
  variableTarget, variableTarget.toString(), enclosingFunction, enclosingFunction.getName()