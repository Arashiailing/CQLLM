/**
 * @name Reuse of loop variable in nested loops after inner loop redefinition
 * @description Detects when a loop variable gets redefined in an inner loop
 *              and subsequently reused in the outer loop, potentially causing
 *              unexpected behavior due to variable shadowing.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/nested-loops-with-same-variable-reused
 */

import python

/* Determines if a loop variable is established via SSA (Static Single Assignment) */
predicate loopVarDefinedBySsa(For loopStmt, Variable targetVar, SsaVariable ssaDef) {
  // Verify the loop's target corresponds to the SSA definition node
  // and maintain consistent variable references
  loopStmt.getTarget().getAFlowNode() = ssaDef.getDefinition() and 
  targetVar = ssaDef.getVariable()
}

/* Identifies variable reuse scenarios across nested loop structures */
predicate nestedLoopVariableReuse(For innerLoop, For outerLoop, Variable sharedVar, Name varRef) {
  /* Inner loop must be directly nested within outer loop's body (excluding else blocks) */
  outerLoop.getBody().contains(innerLoop) and 
  /* Variable must be referenced in outer loop but not in inner loop */
  outerLoop.contains(varRef) and 
  not innerLoop.contains(varRef) and 
  exists(SsaVariable ssaDefinition |
    // Verify inner loop redefines the shared variable
    loopVarDefinedBySsa(innerLoop, sharedVar, ssaDefinition.getAnUltimateDefinition()) and 
    // Confirm outer loop uses the same shared variable
    loopVarDefinedBySsa(outerLoop, sharedVar, _) and 
    // Ensure variable usage corresponds to the target name
    ssaDefinition.getAUse().getNode() = varRef
  )
}

// Main detection logic: Find problematic nested loop variable reuse patterns
from For innerLoop, For outerLoop, Variable sharedVar, Name varRef
where nestedLoopVariableReuse(innerLoop, outerLoop, sharedVar, varRef)
select innerLoop, "Nested for statement $@ loop variable '" + sharedVar.getId() + "' of enclosing $@.", 
       varRef, "uses", outerLoop, "for statement"