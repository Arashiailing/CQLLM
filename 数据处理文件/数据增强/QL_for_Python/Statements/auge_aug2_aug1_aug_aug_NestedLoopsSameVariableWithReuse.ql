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

// Identifies nested for-loop structures where a variable is reused after redefinition
// by an inner loop, potentially causing unexpected behavior in the outer loop
predicate findNestedLoopVarReuse(For innerForLoop, For outerForLoop, Variable reusedVariable, Name variableUsage) {
  // Verify nesting relationship: inner loop directly inside outer loop's body
  outerForLoop.getBody().contains(innerForLoop) and
  
  // Confirm variable usage is in outer loop but not in inner loop
  outerForLoop.contains(variableUsage) and 
  not innerForLoop.contains(variableUsage) and 
  
  // Establish SSA definition relationships for the reused variable
  exists(SsaVariable innerSsaDefinition |
    // Inner loop redefines the variable at its target node
    innerForLoop.getTarget().getAFlowNode() = innerSsaDefinition.getAnUltimateDefinition().getDefinition() and 
    reusedVariable = innerSsaDefinition.getVariable() and 
    
    // Verify outer loop also defines the same variable
    exists(SsaVariable outerSsaDefinition |
      outerForLoop.getTarget().getAFlowNode() = outerSsaDefinition.getDefinition() and 
      reusedVariable = outerSsaDefinition.getVariable()
    ) and 
    
    // Link the variable usage to the inner loop's SSA definition
    innerSsaDefinition.getAUse().getNode() = variableUsage
  )
}

// Query main entry point: Find problematic variable reuse patterns in nested loops
from For innerForLoop, For outerForLoop, Variable reusedVariable, Name variableUsage
where findNestedLoopVarReuse(innerForLoop, outerForLoop, reusedVariable, variableUsage)
select innerForLoop, "Nested for statement $@ loop variable '" + reusedVariable.getId() + "' of enclosing $@.", 
       variableUsage, "uses", outerForLoop, "for statement"