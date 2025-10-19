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

// Detects nested loop structures where a variable is reused after redefinition
predicate findNestedLoopVarReuse(For innerLoop, For outerLoop, Variable reusedVar, Name varUsage) {
  /* Verify variable is used in outer loop but not in inner loop */
  outerLoop.contains(varUsage) and 
  not innerLoop.contains(varUsage) and 
  /* Ensure inner loop is directly nested within outer loop's body (excluding else blocks) */
  outerLoop.getBody().contains(innerLoop) and 
  exists(SsaVariable ssaDefinition |
    // Confirm inner loop redefines the variable
    innerLoop.getTarget().getAFlowNode() = ssaDefinition.getAnUltimateDefinition().getDefinition() and 
    reusedVar = ssaDefinition.getVariable() and 
    // Verify outer loop also uses the same variable
    exists(SsaVariable outerSsaDef |
      outerLoop.getTarget().getAFlowNode() = outerSsaDef.getDefinition() and 
      reusedVar = outerSsaDef.getVariable()
    ) and 
    // Ensure the variable usage corresponds to the SSA definition
    ssaDefinition.getAUse().getNode() = varUsage
  )
}

// Main query: Identify problematic nested loop variable reuse patterns
from For innerLoop, For outerLoop, Variable reusedVar, Name varUsage
where findNestedLoopVarReuse(innerLoop, outerLoop, reusedVar, varUsage)
select innerLoop, "Nested for statement $@ loop variable '" + reusedVar.getId() + "' of enclosing $@.", 
       varUsage, "uses", outerLoop, "for statement"