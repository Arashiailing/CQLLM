/**
 * @name Nested loops with same variable reused after inner loop body
 * @description Detects when a variable is redefined in an inner loop and subsequently
 *              used in an outer loop, leading to unexpected behavior.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/nested-loops-with-same-variable-reused
 */

import python

// Verify if a loop variable is defined via SSA (Static Single Assignment)
predicate checkLoopVarSsaDefinition(For loopStmt, Variable loopVariable, SsaVariable ssaDefinition) {
  // Ensure the loop target node matches the SSA variable definition node
  // and that the variable references are consistent
  loopStmt.getTarget().getAFlowNode() = ssaDefinition.getDefinition() and 
  loopVariable = ssaDefinition.getVariable()
}

// Identify cases of variable reuse in nested loop structures
predicate detectNestedLoopVarReuse(For nestedLoop, For enclosingLoop, Variable loopVariable, Name varReference) {
  /* Confirm the variable usage is in the outer loop, not the inner loop */
  enclosingLoop.contains(varReference) and 
  not nestedLoop.contains(varReference) and 
  /* The inner loop must be directly contained in the outer loop's body (excluding else clauses) */
  enclosingLoop.getBody().contains(nestedLoop) and 
  exists(SsaVariable ssaDefinition |
    // Validate that the inner loop redefines the variable
    checkLoopVarSsaDefinition(nestedLoop, loopVariable, ssaDefinition.getAnUltimateDefinition()) and 
    // Verify the outer loop also uses the same variable
    checkLoopVarSsaDefinition(enclosingLoop, loopVariable, _) and 
    // Ensure the variable usage node matches the target name
    ssaDefinition.getAUse().getNode() = varReference
  )
}

// Main query: Identify nested loop structures with variable reuse issues
from For nestedLoop, For enclosingLoop, Variable reusedVar, Name varReference
where detectNestedLoopVarReuse(nestedLoop, enclosingLoop, reusedVar, varReference)
select nestedLoop, "Nested for statement $@ loop variable '" + reusedVar.getId() + "' of enclosing $@.", 
       varReference, "uses", enclosingLoop, "for statement"