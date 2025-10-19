/**
 * @name Nested loops with same variable reused after inner loop body
 * @description Identifies scenarios where a loop variable is redefined in an inner loop
 *              and subsequently referenced in an outer loop, potentially causing
 *              unintended behavior due to variable shadowing.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/nested-loops-with-same-variable-reused
 */

import python

// Detects loop variable definitions by matching loop targets with SSA definitions
predicate loopVariableDefinition(For loop, Variable iteratedVar, SsaVariable ssaDefinition) {
  loop.getTarget().getAFlowNode() = ssaDefinition.getDefinition() and
  iteratedVar = ssaDefinition.getVariable()
}

// Identifies problematic variable reuse patterns in nested loop structures
predicate nestedLoopVariableReuse(For innerForLoop, For outerForLoop, Variable iteratedVar, Name variableUsage) {
  // Verify inner loop is directly contained within outer loop's body (not else branch)
  outerForLoop.getBody().contains(innerForLoop) and
  // Confirm variable is used in outer loop scope but outside inner loop
  outerForLoop.contains(variableUsage) and
  not innerForLoop.contains(variableUsage) and
  // Validate SSA relationships: variable defined in both loops with usage in outer scope
  exists(SsaVariable innerSsaDef |
    loopVariableDefinition(innerForLoop, iteratedVar, innerSsaDef.getAnUltimateDefinition()) and
    loopVariableDefinition(outerForLoop, iteratedVar, _) and
    innerSsaDef.getAUse().getNode() = variableUsage
  )
}

// Query selecting problematic nested loops with variable reuse
from For innerForLoop, For outerForLoop, Variable iteratedVar, Name variableUsage
where nestedLoopVariableReuse(innerForLoop, outerForLoop, iteratedVar, variableUsage)
select innerForLoop, "Nested for statement $@ loop variable '" + iteratedVar.getId() + "' of enclosing $@.", variableUsage,
  "uses", outerForLoop, "for statement"