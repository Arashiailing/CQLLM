/**
 * @name Nested loops with same variable reused after inner loop body
 * @description Detects redefinition of a loop variable in an inner loop that causes
 *              unexpected behavior when the variable is used in the outer loop.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/nested-loops-with-same-variable-reused
 */

import python

// Determines if a variable is redefined within a loop's iteration target
predicate loopVariableSsaDefinition(For loop, Variable var, SsaVariable ssaVar) {
  loop.getTarget().getAFlowNode() = ssaVar.getDefinition() and 
  var = ssaVar.getVariable()
}

// Identifies when a variable is used in an outer loop after being redefined in an inner loop
predicate variableReusedInOuterLoop(For innerLoop, For outerLoop, Variable var, Name nameNode) {
  /* Exclude cases where variable is unused or only used within inner loop scope */
  outerLoop.contains(nameNode) and
  not innerLoop.contains(nameNode) and
  /* Only consider inner loops directly contained in outer loop body (not else clauses) */
  outerLoop.getBody().contains(innerLoop) and
  exists(SsaVariable innerSsaVar |
    // Verify variable redefinition in inner loop
    loopVariableSsaDefinition(innerLoop, var, innerSsaVar.getAnUltimateDefinition()) and
    // Verify original definition in outer loop
    loopVariableSsaDefinition(outerLoop, var, _) and
    // Confirm usage matches the redefined variable
    innerSsaVar.getAUse().getNode() = nameNode
  )
}

// Query to find problematic nested loop variable reuse patterns
from For innerLoop, For outerLoop, Variable var, Name nameNode
where variableReusedInOuterLoop(innerLoop, outerLoop, var, nameNode)
select innerLoop, "Nested for statement $@ loop variable '" + var.getId() + "' of enclosing $@.", 
       nameNode, "uses", outerLoop, "for statement"