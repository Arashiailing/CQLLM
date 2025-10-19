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

// Detects problematic variable reuse in nested loop constructs
predicate hasNestedLoopVariableReuse(For innerForLoop, For outerForLoop, Variable sharedVar, Name usageNode) {
  // Usage must be in outer loop scope but outside inner loop scope
  outerForLoop.contains(usageNode) and
  not innerForLoop.contains(usageNode) and
  // Inner loop must be directly nested within outer loop body
  outerForLoop.getBody().contains(innerForLoop) and
  // Verify outer loop defines the shared variable
  exists(SsaVariable outerSsaVar |
    outerForLoop.getTarget().getAFlowNode() = outerSsaVar.getDefinition() and 
    sharedVar = outerSsaVar.getVariable()
  ) and
  // Verify inner loop redefines the same variable and usage is affected
  exists(SsaVariable innerSsaVar |
    innerForLoop.getTarget().getAFlowNode() = innerSsaVar.getAnUltimateDefinition().getDefinition() and 
    sharedVar = innerSsaVar.getAnUltimateDefinition().getVariable() and
    innerSsaVar.getAUse().getNode() = usageNode
  )
}

// Query for detecting problematic variable reuse in nested loops
from For innerForLoop, For outerForLoop, Variable sharedVar, Name usageNode
where hasNestedLoopVariableReuse(innerForLoop, outerForLoop, sharedVar, usageNode)
select innerForLoop, 
  "Nested for statement $@ loop variable '" + sharedVar.getId() + "' of enclosing $@.", 
  usageNode, "uses", outerForLoop, "for statement"