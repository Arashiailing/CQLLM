/**
 * @name Nested loops with same variable reused after inner loop body
 * @description In nested loops, if an inner loop redefines a variable that is also used in the outer loop,
 *              and the variable is used in the outer loop after the inner loop, the behavior may be unexpected.
 *              Specifically, the variable in the outer loop will take the value from the inner loop's last iteration.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/nested-loops-with-same-variable-reused
 */

import python

// Identify variable reuse scenarios in nested loops where:
// 1. The same variable is defined in both inner and outer loops
// 2. The variable is referenced in the outer loop after the inner loop
// 3. The reference uses the value from the inner loop's last iteration
predicate hasNestedLoopVariableReuse(For innerLoop, For outerLoop, Variable reusedVar, Name nameNode) {
  // Usage must occur in outer loop scope but outside inner loop scope
  outerLoop.contains(nameNode) and
  not innerLoop.contains(nameNode) and
  // Inner loop must be directly nested within outer loop body
  outerLoop.getBody().contains(innerLoop) and
  // Verify outer loop defines the reused variable
  exists(SsaVariable outerSsaVar |
    outerLoop.getTarget().getAFlowNode() = outerSsaVar.getDefinition() and 
    reusedVar = outerSsaVar.getVariable()
  ) and
  // Verify inner loop redefines the same variable and usage is affected
  exists(SsaVariable innerSsaVar |
    innerLoop.getTarget().getAFlowNode() = innerSsaVar.getAnUltimateDefinition().getDefinition() and 
    reusedVar = innerSsaVar.getAnUltimateDefinition().getVariable() and
    innerSsaVar.getAUse().getNode() = nameNode
  )
}

// Query for detecting problematic variable reuse in nested loops
from For innerLoop, For outerLoop, Variable reusedVar, Name nameNode
where hasNestedLoopVariableReuse(innerLoop, outerLoop, reusedVar, nameNode)
select innerLoop, 
  "Nested for statement $@ loop variable '" + reusedVar.getId() + "' of enclosing $@.", 
  nameNode, "uses", outerLoop, "for statement"