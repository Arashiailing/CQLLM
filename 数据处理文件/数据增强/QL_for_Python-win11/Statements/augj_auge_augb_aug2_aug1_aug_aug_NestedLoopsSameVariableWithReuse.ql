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
 * 1. Inner loop directly nested in outer loop body
 * 2. Variable referenced in outer loop scope but not inner loop scope
 * 3. Inner loop redefines outer loop's variable
 * 4. Variable usage corresponds to inner loop's SSA definition
 */
predicate findNestedLoopVarReuse(For innerLoop, For outerLoop, Variable loopVar, Name varRef) {
  // Verify structural nesting relationship
  outerLoop.getBody().contains(innerLoop) and 
  
  // Verify variable usage scope conditions
  outerLoop.contains(varRef) and 
  not innerLoop.contains(varRef) and 
  
  // Check SSA relationships between loop variable definitions
  exists(SsaVariable innerSsa, SsaVariable outerSsa |
    // Inner loop redefines the outer loop variable
    innerLoop.getTarget().getAFlowNode() = innerSsa.getAnUltimateDefinition().getDefinition() and 
    loopVar = innerSsa.getVariable() and 
    
    // Outer loop uses the same loop variable
    outerLoop.getTarget().getAFlowNode() = outerSsa.getDefinition() and 
    loopVar = outerSsa.getVariable() and 
    
    // Variable reference corresponds to inner loop's SSA definition
    innerSsa.getAUse().getNode() = varRef
  )
}

// Main query: Detect problematic patterns of nested loop variable reuse
from For innerLoop, For outerLoop, Variable loopVar, Name varRef
where findNestedLoopVarReuse(innerLoop, outerLoop, loopVar, varRef)
select innerLoop, "Nested for statement $@ loop variable '" + loopVar.getId() + "' of enclosing $@.", 
       varRef, "uses", outerLoop, "for statement"