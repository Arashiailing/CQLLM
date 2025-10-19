/**
 * @name Unnecessary delete statement in function
 * @description Detects redundant 'delete' statements for local variables.
 *              Such deletions are unnecessary since variables are automatically
 *              cleaned up when the function scope exits.
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
 * Checks if an AST node resides within any loop construct.
 * Recursively verifies whether the node is nested inside While/For loops
 * or contained within child nodes of loop structures.
 */
predicate isWithinLoopContext(AstNode node) {
  // Direct parent is a loop (base case)
  node.getParentNode() instanceof While
  or
  node.getParentNode() instanceof For
  or
  // Recursive check: node is child of another loop-contained node
  exists(AstNode loopContainer | 
    isWithinLoopContext(loopContainer) and 
    node = loopContainer.getAChildNode()
  )
}

// Identify redundant delete operations in function scopes
from Delete redundantDelete, Expr variableTarget, Function hostFunction
where
  // Core condition: delete is function's final statement
  hostFunction.getLastStatement() = redundantDelete and
  
  // Target validation: variable must be in function scope
  variableTarget = redundantDelete.getATarget() and
  hostFunction.containsInScope(variableTarget) and
  
  // Exclusion 1: skip complex deletion targets
  not (
    variableTarget instanceof Subscript or
    variableTarget instanceof Attribute
  ) and
  
  // Exclusion 2: skip deletes within loop structures
  not isWithinLoopContext(redundantDelete) and
  
  // Exclusion 3: skip functions using sys.exc_info
  not exists(FunctionValue excInfoCall |
    excInfoCall = Value::named("sys.exc_info") and
    excInfoCall.getACall().getScope() = hostFunction
  )
select redundantDelete, "Redundant deletion of local variable $@ in function $@.", variableTarget, variableTarget.toString(), hostFunction,
  hostFunction.getName()