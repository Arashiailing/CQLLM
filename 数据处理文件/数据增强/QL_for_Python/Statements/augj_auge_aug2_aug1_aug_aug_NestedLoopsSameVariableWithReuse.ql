/**
 * @name Reuse of loop variable in nested loops after inner loop redefinition
 * @description Detects cases where a loop variable is redefined within an inner loop
 *              and subsequently utilized in the outer loop, leading to potential logic errors.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/nested-loops-with-same-variable-reused
 */

import python

// Locates instances of nested for-loops where a variable is reused after being
// redefined in an inner loop, which may result in unintended program behavior
predicate detectNestedLoopVarConflict(For nestedForLoop, For enclosingForLoop, Variable conflictedVar, Name varReference) {
  // Ensure the inner loop is directly contained within the outer loop's body
  enclosingForLoop.getBody().contains(nestedForLoop) and
  
  // Confirm the variable reference occurs in the outer loop but not in the inner loop
  enclosingForLoop.contains(varReference) and 
  not nestedForLoop.contains(varReference) and 
  
  // Establish SSA definition relationships for the conflicted variable
  exists(SsaVariable nestedSsaDef |
    // The inner loop redefines the variable at its target node
    nestedForLoop.getTarget().getAFlowNode() = nestedSsaDef.getAnUltimateDefinition().getDefinition() and 
    conflictedVar = nestedSsaDef.getVariable() and 
    
    // Verify the outer loop also defines the same variable
    exists(SsaVariable enclosingSsaDef |
      enclosingForLoop.getTarget().getAFlowNode() = enclosingSsaDef.getDefinition() and 
      conflictedVar = enclosingSsaDef.getVariable()
    ) and 
    
    // Connect the variable reference to the inner loop's SSA definition
    nestedSsaDef.getAUse().getNode() = varReference
  )
}

// Main query entry point: Identify problematic variable reuse patterns in nested loops
from For nestedForLoop, For enclosingForLoop, Variable conflictedVar, Name varReference
where detectNestedLoopVarConflict(nestedForLoop, enclosingForLoop, conflictedVar, varReference)
select nestedForLoop, "Nested for statement $@ loop variable '" + conflictedVar.getId() + "' of enclosing $@.", 
       varReference, "uses", enclosingForLoop, "for statement"