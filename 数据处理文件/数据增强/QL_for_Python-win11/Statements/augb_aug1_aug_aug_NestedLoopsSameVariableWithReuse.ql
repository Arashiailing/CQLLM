/**
 * @name Reuse of loop variable in nested loops after inner loop redefinition
 * @description Identifies scenarios where a loop variable is redefined in an inner loop
 *              and then used in the outer loop, which can cause unintended behavior.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/nested-loops-with-same-variable-reused
 */

import python

/* Determines if a loop variable is defined through SSA (Static Single Assignment) mechanism */
predicate isLoopVarDefinedBySsa(For forLoop, Variable loopVar, SsaVariable ssaDefinition) {
  // Verify the loop's target corresponds to the SSA definition node
  // and ensure consistent variable references
  forLoop.getTarget().getAFlowNode() = ssaDefinition.getDefinition() and 
  loopVar = ssaDefinition.getVariable()
}

/* Identifies cases where a variable is reused across nested loop structures */
predicate findNestedLoopVarReuse(For nestedLoop, For enclosingLoop, Variable reusedVar, Name variableReference) {
  /* The inner loop must be directly nested within the outer loop's body (excluding else blocks) */
  enclosingLoop.getBody().contains(nestedLoop) and 
  /* The variable must be referenced in the outer loop but not in the inner loop */
  enclosingLoop.contains(variableReference) and 
  not nestedLoop.contains(variableReference) and 
  exists(SsaVariable ssaDefinition |
    // Verify the inner loop redefines the variable
    isLoopVarDefinedBySsa(nestedLoop, reusedVar, ssaDefinition.getAnUltimateDefinition()) and 
    // Confirm the outer loop uses the same variable
    isLoopVarDefinedBySsa(enclosingLoop, reusedVar, _) and 
    // Ensure the variable usage corresponds to the target name
    ssaDefinition.getAUse().getNode() = variableReference
  )
}

// Main query: Detect problematic nested loop variable reuse patterns
from For nestedLoop, For enclosingLoop, Variable reusedVar, Name variableReference
where findNestedLoopVarReuse(nestedLoop, enclosingLoop, reusedVar, variableReference)
select nestedLoop, "Nested for statement $@ loop variable '" + reusedVar.getId() + "' of enclosing $@.", 
       variableReference, "uses", enclosingLoop, "for statement"