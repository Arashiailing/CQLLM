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
predicate findNestedLoopVarReuse(For nestedLoop, For enclosingLoop, Variable conflictingVar, Name varRef) {
  // Ensure nested loop is directly contained within outer loop's body (excluding else blocks)
  enclosingLoop.getBody().contains(nestedLoop) and
  // Verify variable is referenced in outer loop but not in inner loop
  enclosingLoop.contains(varRef) and 
  not nestedLoop.contains(varRef) and 
  exists(SsaVariable innerSsaDef |
    // Confirm inner loop redefines the conflicting variable
    nestedLoop.getTarget().getAFlowNode() = innerSsaDef.getAnUltimateDefinition().getDefinition() and 
    conflictingVar = innerSsaDef.getVariable() and 
    // Verify outer loop also uses the same variable
    exists(SsaVariable outerSsaDef |
      enclosingLoop.getTarget().getAFlowNode() = outerSsaDef.getDefinition() and 
      conflictingVar = outerSsaDef.getVariable()
    ) and 
    // Ensure the variable reference corresponds to the SSA definition
    innerSsaDef.getAUse().getNode() = varRef
  )
}

// Main query: Identify problematic nested loop variable reuse patterns
from For nestedLoop, For enclosingLoop, Variable conflictingVar, Name varRef
where findNestedLoopVarReuse(nestedLoop, enclosingLoop, conflictingVar, varRef)
select nestedLoop, "Nested for statement $@ loop variable '" + conflictingVar.getId() + "' of enclosing $@.", 
       varRef, "uses", enclosingLoop, "for statement"