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

// Check whether a loop variable is defined by an SSA (Static Single Assignment) definition
predicate isLoopVarDefinedBySsa(For loop, Variable var, SsaVariable ssaDef) {
  // Confirm that the loop target node corresponds to the SSA definition node
  // and that the variable references are consistent
  loop.getTarget().getAFlowNode() = ssaDef.getDefinition() and 
  var = ssaDef.getVariable()
}

// Detect instances of variable reuse within nested loop constructs
predicate findNestedLoopVarReuse(For innerLoop, For outerLoop, Variable var, Name varRef) {
  /* Ensure the variable is used in the outer loop but not in the inner loop */
  outerLoop.contains(varRef) and 
  not innerLoop.contains(varRef) and 
  /* The inner loop must be directly nested within the body of the outer loop (excluding else blocks) */
  outerLoop.getBody().contains(innerLoop) and 
  exists(SsaVariable ssaDef |
    // Confirm that the inner loop redefines the variable
    isLoopVarDefinedBySsa(innerLoop, var, ssaDef.getAnUltimateDefinition()) and 
    // Check that the outer loop also uses the same variable
    isLoopVarDefinedBySsa(outerLoop, var, _) and 
    // Verify that the variable usage node corresponds to the target name
    ssaDef.getAUse().getNode() = varRef
  )
}

// Main query: Identify nested loop structures with variable reuse issues
from For innerLoop, For outerLoop, Variable reusedVariable, Name varRef
where findNestedLoopVarReuse(innerLoop, outerLoop, reusedVariable, varRef)
select innerLoop, "Nested for statement $@ loop variable '" + reusedVariable.getId() + "' of enclosing $@.", 
       varRef, "uses", outerLoop, "for statement"