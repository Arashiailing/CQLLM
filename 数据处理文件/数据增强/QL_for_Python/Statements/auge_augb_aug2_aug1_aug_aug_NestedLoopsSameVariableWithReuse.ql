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
 * Detects problematic nested loop patterns where:
 * 1. Inner loop redefines a variable from the outer loop
 * 2. The redefined variable is later used in the outer loop
 * 3. The usage occurs outside the inner loop's scope
 */
predicate findNestedLoopVarReuse(For innerLoop, For outerLoop, Variable loopVar, Name varRef) {
  // Structural relationship: inner loop directly nested in outer loop body
  outerLoop.getBody().contains(innerLoop) and 
  
  // Variable usage pattern: referenced in outer loop but not in inner loop
  outerLoop.contains(varRef) and 
  not innerLoop.contains(varRef) and 
  
  // SSA variable relationships between loops
  exists(SsaVariable innerSsaDef |
    // Inner loop redefines the loop variable
    innerLoop.getTarget().getAFlowNode() = innerSsaDef.getAnUltimateDefinition().getDefinition() and 
    loopVar = innerSsaDef.getVariable() and 
    
    // Outer loop uses the same loop variable
    exists(SsaVariable outerSsaDef |
      outerLoop.getTarget().getAFlowNode() = outerSsaDef.getDefinition() and 
      loopVar = outerSsaDef.getVariable()
    ) and 
    
    // Variable reference points to inner loop's SSA definition
    innerSsaDef.getAUse().getNode() = varRef
  )
}

// Main query: Detect problematic patterns of nested loop variable reuse
from For innerLoop, For outerLoop, Variable loopVar, Name varRef
where findNestedLoopVarReuse(innerLoop, outerLoop, loopVar, varRef)
select innerLoop, "Nested for statement $@ loop variable '" + loopVar.getId() + "' of enclosing $@.", 
       varRef, "uses", outerLoop, "for statement"