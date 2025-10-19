/**
 * @name Nested loops with same variable reused after inner loop body
 * @description Detects when an inner loop redefines a variable that is subsequently 
 *              used in the outer loop, leading to unexpected behavior.
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
 * Determines if a loop defines a variable's SSA version.
 * @param loopNode - The loop statement being checked
 * @param var - The variable being defined
 * @param ssaVar - The SSA variable representation
 */
predicate loop_variable_ssa(For loopNode, Variable var, SsaVariable ssaVar) {
  loopNode.getTarget().getAFlowNode() = ssaVar.getDefinition() and 
  var = ssaVar.getVariable()
}

/**
 * Identifies problematic variable reuse in nested loops.
 * @param innerLoop - The inner loop statement
 * @param outerLoop - The outer loop statement
 * @param var - The reused variable
 * @param nameNode - The usage location of the variable
 */
predicate variableUsedInNestedLoops(For innerLoop, For outerLoop, Variable var, Name nameNode) {
  // Ensure usage occurs in outer loop but not inner loop
  outerLoop.contains(nameNode) and 
  not innerLoop.contains(nameNode) and
  
  // Verify inner loop is directly nested in outer loop's body (not else clause)
  outerLoop.getBody().contains(innerLoop) and
  
  exists(SsaVariable ssaVar |
    // Confirm variable redefinition in inner loop
    loop_variable_ssa(innerLoop, var, ssaVar.getAnUltimateDefinition()) and
    
    // Verify variable was originally defined in outer loop
    loop_variable_ssa(outerLoop, var, _) and
    
    // Identify specific usage location
    ssaVar.getAUse().getNode() = nameNode
  )
}

// Query execution: Find instances of problematic variable reuse
from For inner, For outer, Variable v, Name n
where variableUsedInNestedLoops(inner, outer, v, n)
select inner, "Nested for statement $@ loop variable '" + v.getId() + "' of enclosing $@.", n,
  "uses", outer, "for statement"