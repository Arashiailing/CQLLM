/**
 * @name Reuse of loop variable in nested loops after inner loop redefinition
 * @description Detects instances where a loop variable is redefined within an inner loop
 *              and subsequently referenced in the outer loop, potentially leading to unexpected behavior.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/nested-loops-with-same-variable-reused
 */

import python

/* Checks if a loop variable is established via SSA (Static Single Assignment) mechanism */
predicate isLoopVarSsaDefined(For loopStmt, Variable iteratedVar, SsaVariable ssaDef) {
  // Confirm that the loop's target corresponds to the SSA definition node
  // and maintain consistent variable references
  loopStmt.getTarget().getAFlowNode() = ssaDef.getDefinition() and 
  iteratedVar = ssaDef.getVariable()
}

/* Finds instances where a variable is shared across nested loop structures */
predicate detectNestedLoopVarReuse(For innerLoop, For outerLoop, Variable sharedVar, Name varRef) {
  /* The inner loop must be directly contained within the outer loop's body (excluding else blocks) */
  outerLoop.getBody().contains(innerLoop) and 
  /* The variable must be referenced in the outer loop but not in the inner loop */
  outerLoop.contains(varRef) and 
  not innerLoop.contains(varRef) and 
  exists(SsaVariable ssaDef |
    // Verify the inner loop redefines the variable
    isLoopVarSsaDefined(innerLoop, sharedVar, ssaDef.getAnUltimateDefinition()) and 
    // Confirm the outer loop uses the same variable
    isLoopVarSsaDefined(outerLoop, sharedVar, _) and 
    // Ensure the variable usage corresponds to the target name
    ssaDef.getAUse().getNode() = varRef
  )
}

// Main query: Identify problematic nested loop variable reuse patterns
from For innerLoop, For outerLoop, Variable sharedVar, Name varRef
where detectNestedLoopVarReuse(innerLoop, outerLoop, sharedVar, varRef)
select innerLoop, "Nested for statement $@ loop variable '" + sharedVar.getId() + "' of enclosing $@.", 
       varRef, "uses", outerLoop, "for statement"