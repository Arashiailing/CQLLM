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

// Identifies variable misuse in nested loops where:
// 1. Variable is used in outer loop but not in inner loop
// 2. Inner loop is contained within outer loop body
// 3. Inner loop redefines the variable (via SSA)
// 4. Outer loop also defines the same variable
// 5. Variable usage corresponds to SSA definition
predicate hasVariableMisuseInNestedLoops(For innerForLoop, For outerForLoop, Variable reusedVar, Name usageNode) {
  // Variable usage occurs in outer loop scope but not inner loop
  outerForLoop.contains(usageNode) and
  not innerForLoop.contains(usageNode) and
  // Inner loop is nested inside outer loop body (excluding else clauses)
  outerForLoop.getBody().contains(innerForLoop) and
  // Track SSA variable redefinition and usage chain
  exists(SsaVariable ssaVar |
    // Inner loop redefines variable via SSA ultimate definition
    innerForLoop.getTarget().getAFlowNode() = ssaVar.getAnUltimateDefinition().getDefinition() and 
    reusedVar = ssaVar.getAnUltimateDefinition().getVariable() and
    // Outer loop also defines same variable
    exists(SsaVariable outerSsaVar | 
        outerForLoop.getTarget().getAFlowNode() = outerSsaVar.getDefinition() and 
        reusedVar = outerSsaVar.getVariable()
    ) and
    // Usage node matches SSA variable usage
    ssaVar.getAUse().getNode() = usageNode
  )
}

// Query for variable redefinition issues in nested loops
from For innerForLoop, For outerForLoop, Variable reusedVar, Name usageNode
where hasVariableMisuseInNestedLoops(innerForLoop, outerForLoop, reusedVar, usageNode)
select innerForLoop, 
  "Nested for statement $@ loop variable '" + reusedVar.getId() + "' of enclosing $@.", 
  usageNode, "uses", outerForLoop, "for statement"