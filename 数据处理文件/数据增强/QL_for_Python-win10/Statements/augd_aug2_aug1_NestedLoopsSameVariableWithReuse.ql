/**
 * @name Nested loops with same variable reused after inner loop body
 * @description When nested loops share a loop variable name, and the inner loop redefines this variable,
 *              subsequent uses in the outer loop will unexpectedly retain the inner loop's final value.
 *              This occurs because the variable gets redefined within the inner loop's scope.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/nested-loops-with-same-variable-reused
 */

import python

// Determine if a loop variable corresponds to an SSA variable definition
predicate isLoopVarSsaDefinition(For loopStmt, Variable targetVar, SsaVariable ssaDef) {
  // Verify the loop's target node matches the SSA definition node
  loopStmt.getTarget().getAFlowNode() = ssaDef.getDefinition() and 
  targetVar = ssaDef.getVariable()
}

// Identify problematic variable reuse in nested loop structures
predicate problematicNestedLoopReuse(For innerLoop, For outerLoop, Variable commonVar, Name useNode) {
  /* Usage must occur in outer loop scope but outside inner loop scope */
  outerLoop.contains(useNode) and
  not innerLoop.contains(useNode) and
  /* Inner loop must be directly nested within outer loop body (excluding else clauses) */
  outerLoop.getBody().contains(innerLoop) and
  /* Track variable redefinition through SSA analysis */
  exists(SsaVariable ssaDef |
    // Inner loop redefines the variable (via ultimate SSA definition)
    isLoopVarSsaDefinition(innerLoop, commonVar, ssaDef.getAnUltimateDefinition()) and
    // Outer loop also defines the same variable
    isLoopVarSsaDefinition(outerLoop, commonVar, _) and
    // Usage corresponds to SSA variable usage
    ssaDef.getAUse().getNode() = useNode
  )
}

// Query for variable redefinition issues in nested loops
from For innerLoop, For outerLoop, Variable commonVar, Name useNode
where problematicNestedLoopReuse(innerLoop, outerLoop, commonVar, useNode)
select innerLoop, 
  "Nested for statement $@ loop variable '" + commonVar.getId() + "' of enclosing $@.", 
  useNode, "uses", outerLoop, "for statement"