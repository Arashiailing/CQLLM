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

// Detects nested for-loop structures where a variable is reused after redefinition
// by an inner loop, potentially causing unexpected behavior in the outer loop
predicate findNestedLoopVarReuse(For innerLoop, For outerLoop, Variable reusedVar, Name varUsage) {
  // Validate nesting relationship: inner loop directly nested within outer loop's body
  outerLoop.getBody().contains(innerLoop) and
  
  // Ensure variable usage occurs in outer loop but not in inner loop
  outerLoop.contains(varUsage) and 
  not innerLoop.contains(varUsage) and 
  
  // Establish SSA definition relationships for the reused variable
  exists(SsaVariable innerSsaDef |
    // Inner loop redefines the variable at its target node
    innerLoop.getTarget().getAFlowNode() = innerSsaDef.getAnUltimateDefinition().getDefinition() and 
    reusedVar = innerSsaDef.getVariable() and 
    
    // Verify outer loop also defines the same variable
    exists(SsaVariable outerSsaDef |
      outerLoop.getTarget().getAFlowNode() = outerSsaDef.getDefinition() and 
      reusedVar = outerSsaDef.getVariable()
    ) and 
    
    // Connect variable usage to inner loop's SSA definition
    innerSsaDef.getAUse().getNode() = varUsage
  )
}

// Query main entry point: Find problematic variable reuse patterns in nested loops
from For innerLoop, For outerLoop, Variable reusedVar, Name varUsage
where findNestedLoopVarReuse(innerLoop, outerLoop, reusedVar, varUsage)
select innerLoop, "Nested for statement $@ loop variable '" + reusedVar.getId() + "' of enclosing $@.", 
       varUsage, "uses", outerLoop, "for statement"