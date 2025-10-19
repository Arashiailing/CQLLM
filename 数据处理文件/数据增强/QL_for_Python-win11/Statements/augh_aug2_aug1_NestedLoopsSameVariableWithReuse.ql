/**
 * @name Nested loops with same variable reused after inner loop body
 * @description Detects when an inner loop redefines a variable used in the outer loop,
 *              and that variable is subsequently used in the outer loop after the inner loop.
 *              This leads to unexpected behavior where the outer loop variable retains
 *              the value from the inner loop's final iteration.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/nested-loops-with-same-variable-reused
 */

import python

// Check if a loop variable corresponds to an SSA variable definition
predicate loopVarMatchesSsa(For loopStmt, Variable loopVar, SsaVariable ssaVar) {
  // Verify the loop's target node matches the SSA definition node
  loopStmt.getTarget().getAFlowNode() = ssaVar.getDefinition() and 
  loopVar = ssaVar.getVariable()
}

// Identify variable redefinition and misuse patterns in nested loops
predicate nestedLoopVarMisuse(For innerLoop, For outerLoop, Variable reusedVar, Name problematicUsage) {
  /* Problematic usage must be in outer loop scope but outside inner loop scope */
  outerLoop.contains(problematicUsage) and
  not innerLoop.contains(problematicUsage) and
  /* Inner loop must be directly nested within outer loop body (excluding else clauses) */
  outerLoop.getBody().contains(innerLoop) and
  /* Track variable redefinition through SSA variables */
  exists(SsaVariable ssaVar |
    // Inner loop redefines the variable (via ultimate SSA definition)
    loopVarMatchesSsa(innerLoop, reusedVar, ssaVar.getAnUltimateDefinition()) and
    // Outer loop also defines the same variable
    loopVarMatchesSsa(outerLoop, reusedVar, _) and
    // Problematic usage corresponds to SSA variable usage
    ssaVar.getAUse().getNode() = problematicUsage
  )
}

// Query for variable redefinition issues in nested loops
from For innerLoop, For outerLoop, Variable reusedVar, Name problematicUsage
where nestedLoopVarMisuse(innerLoop, outerLoop, reusedVar, problematicUsage)
select innerLoop, 
  "Nested for statement $@ loop variable '" + reusedVar.getId() + "' of enclosing $@.", 
  problematicUsage, "uses", outerLoop, "for statement"