/**
 * @name Nested loops with same variable reused after inner loop body
 * @description Detects when a variable defined in an outer loop is redefined in an inner loop,
 *              and subsequently used in the outer loop after the inner loop. This pattern
 *              can lead to unexpected behavior as the outer loop variable will retain the value
 *              from the inner loop's last iteration.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/nested-loops-with-same-variable-reused
 */

import python

// Verify if a loop variable is associated with an SSA variable definition
predicate isLoopVariableSsa(For loop, Variable loopVar, SsaVariable ssaDefinition) {
  // Check if the loop's target node matches the SSA variable's definition node
  // and ensure the variable references are consistent
  loop.getTarget().getAFlowNode() = ssaDefinition.getDefinition() and 
  loopVar = ssaDefinition.getVariable()
}

// Identify scenarios where a variable is redefined in nested loops and misused
predicate hasVariableReuseInNestedLoops(For nestedLoop, For enclosingLoop, Variable loopVar, Name variableUsage) {
  /* The enclosing loop contains the variable usage, but the nested loop does not
     (ensuring the usage is in the outer scope) */
  enclosingLoop.contains(variableUsage) and
  not nestedLoop.contains(variableUsage) and
  /* The nested loop must be located within the body of the enclosing loop
     (excluding loops in else clauses) */
  enclosingLoop.getBody().contains(nestedLoop) and
  /* Track variable redefinition and usage chain through SSA variables */
  exists(SsaVariable ssaDefinition |
    // The nested loop redefines the variable (via the SSA variable's ultimate definition)
    isLoopVariableSsa(nestedLoop, loopVar, ssaDefinition.getAnUltimateDefinition()) and
    // The enclosing loop also defines a variable with the same name
    isLoopVariableSsa(enclosingLoop, loopVar, _) and
    // The variable usage node matches the SSA variable's use node
    ssaDefinition.getAUse().getNode() = variableUsage
  )
}

// Query for variable redefinition issues in nested loops
from For nestedLoop, For enclosingLoop, Variable loopVar, Name variableUsage
where hasVariableReuseInNestedLoops(nestedLoop, enclosingLoop, loopVar, variableUsage)
select nestedLoop, 
  "Nested for statement $@ loop variable '" + loopVar.getId() + "' of enclosing $@.", 
  variableUsage, "uses", enclosingLoop, "for statement"