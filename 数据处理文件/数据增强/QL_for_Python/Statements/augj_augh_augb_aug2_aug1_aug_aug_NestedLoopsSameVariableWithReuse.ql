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
 * Detects problematic variable reuse patterns where an inner loop redefines
 * a variable that is subsequently referenced in the outer loop scope,
 * creating potential semantic confusion.
 */
predicate hasVariableReuseInNestedLoops(For innerFor, For outerFor, Variable reusedVar, Name varReference) {
  // Verify structural nesting relationship between loops
  outerFor.getBody().contains(innerFor) and 
  
  // Confirm variable usage occurs in outer scope but not inner scope
  outerFor.contains(varReference) and 
  not innerFor.contains(varReference) and 
  
  // Perform SSA analysis to track variable definitions and usage
  exists(SsaVariable innerSsaDef |
    // Inner loop redefines the target variable
    innerFor.getTarget().getAFlowNode() = innerSsaDef.getAnUltimateDefinition().getDefinition() and 
    reusedVar = innerSsaDef.getVariable() and 
    
    // Outer loop uses the same variable in its iteration
    exists(SsaVariable outerSsaDef |
      outerFor.getTarget().getAFlowNode() = outerSsaDef.getDefinition() and 
      reusedVar = outerSsaDef.getVariable()
    ) and 
    
    // The problematic usage references the SSA definition from inner loop
    innerSsaDef.getAUse().getNode() = varReference
  )
}

// Main query: Identify problematic nested loop variable reuse patterns
from For innerFor, For outerFor, Variable reusedVar, Name varReference
where hasVariableReuseInNestedLoops(innerFor, outerFor, reusedVar, varReference)
select innerFor, "Nested for statement $@ loop variable '" + reusedVar.getId() + "' of enclosing $@.", 
       varReference, "uses", outerFor, "for statement"