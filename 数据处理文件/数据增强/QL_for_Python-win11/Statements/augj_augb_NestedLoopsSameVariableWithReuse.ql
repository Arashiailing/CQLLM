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

// Verifies if a variable is defined within a loop's iteration target
predicate isVariableDefinedInLoop(For loopStmt, Variable targetVar, SsaVariable ssaDefinition) {
  loopStmt.getTarget().getAFlowNode() = ssaDefinition.getDefinition() and 
  targetVar = ssaDefinition.getVariable()
}

// Identifies cases where a loop variable is reused in an outer loop after being redefined in an inner loop
predicate hasVariableReuseInOuterLoop(For innerForLoop, For outerForLoop, Variable reusedVar, Name usageNode) {
  /* Exclude scenarios where variable is unused or only referenced within inner loop scope */
  outerForLoop.contains(usageNode) and
  not innerForLoop.contains(usageNode) and
  /* Only examine inner loops directly nested within outer loop body (excluding else clauses) */
  outerForLoop.getBody().contains(innerForLoop) and
  exists(SsaVariable innerLoopSsaVar |
    // Confirm variable redefinition occurs in inner loop
    isVariableDefinedInLoop(innerForLoop, reusedVar, innerLoopSsaVar.getAnUltimateDefinition()) and
    // Verify original definition exists in outer loop
    isVariableDefinedInLoop(outerForLoop, reusedVar, _) and
    // Ensure the usage corresponds to the redefined variable
    innerLoopSsaVar.getAUse().getNode() = usageNode
  )
}

// Query to detect problematic patterns of nested loop variable reuse
from For innerForLoop, For outerForLoop, Variable reusedVar, Name usageNode
where hasVariableReuseInOuterLoop(innerForLoop, outerForLoop, reusedVar, usageNode)
select innerForLoop, "Nested for statement $@ loop variable '" + reusedVar.getId() + "' of enclosing $@.", 
       usageNode, "uses", outerForLoop, "for statement"