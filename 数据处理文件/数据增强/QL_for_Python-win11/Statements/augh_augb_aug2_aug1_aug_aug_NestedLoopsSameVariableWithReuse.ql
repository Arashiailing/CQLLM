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

/**
 * Detects when a loop variable is redefined in an inner loop and subsequently
 * referenced in the outer loop, creating potential semantic confusion.
 */
predicate hasVariableReuseInNestedLoops(For innerLoop, For outerLoop, Variable targetVar, Name varUsage) {
  // Structural relationship: inner loop is nested directly inside outer loop body
  outerLoop.getBody().contains(innerLoop) and 
  
  // Variable usage pattern: referenced in outer scope but not in inner scope
  outerLoop.contains(varUsage) and 
  not innerLoop.contains(varUsage) and 
  
  // SSA analysis to verify variable definition relationships
  exists(SsaVariable innerSsaDefinition |
    // Inner loop redefines the target variable
    innerLoop.getTarget().getAFlowNode() = innerSsaDefinition.getAnUltimateDefinition().getDefinition() and 
    targetVar = innerSsaDefinition.getVariable() and 
    
    // Outer loop also uses the same variable
    exists(SsaVariable outerSsaDefinition |
      outerLoop.getTarget().getAFlowNode() = outerSsaDefinition.getDefinition() and 
      targetVar = outerSsaDefinition.getVariable()
    ) and 
    
    // The usage references the SSA definition from inner loop
    innerSsaDefinition.getAUse().getNode() = varUsage
  )
}

// Main query: Identify problematic nested loop variable reuse patterns
from For innerLoop, For outerLoop, Variable targetVar, Name varUsage
where hasVariableReuseInNestedLoops(innerLoop, outerLoop, targetVar, varUsage)
select innerLoop, "Nested for statement $@ loop variable '" + targetVar.getId() + "' of enclosing $@.", 
       varUsage, "uses", outerLoop, "for statement"