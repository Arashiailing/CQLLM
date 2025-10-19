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

// Verify if a loop variable corresponds to an SSA variable definition
predicate loopVarMatchesSsa(For forStmt, Variable loopVar, SsaVariable ssaVar) {
  // Check if the loop's target node matches the SSA definition node
  forStmt.getTarget().getAFlowNode() = ssaVar.getDefinition() and 
  loopVar = ssaVar.getVariable()
}

// Detect variable redefinition and misuse scenarios in nested loops
predicate nestedLoopVarMisuse(For innerFor, For outerFor, Variable sharedVar, Name usageNode) {
  /* Usage node must be in outer loop scope but not in inner loop scope */
  outerFor.contains(usageNode) and
  not innerFor.contains(usageNode) and
  /* Inner loop must be directly contained in outer loop body (excluding else clauses) */
  outerFor.getBody().contains(innerFor) and
  /* Track variable redefinition and usage through SSA variables */
  exists(SsaVariable ssaVar |
    // Inner loop redefines the variable (via ultimate SSA definition)
    loopVarMatchesSsa(innerFor, sharedVar, ssaVar.getAnUltimateDefinition()) and
    // Outer loop also defines the same variable
    loopVarMatchesSsa(outerFor, sharedVar, _) and
    // Usage node corresponds to SSA variable usage
    ssaVar.getAUse().getNode() = usageNode
  )
}

// Query for variable redefinition issues in nested loops
from For innerLoop, For outerLoop, Variable var, Name nameNode
where nestedLoopVarMisuse(innerLoop, outerLoop, var, nameNode)
select innerLoop, 
  "Nested for statement $@ loop variable '" + var.getId() + "' of enclosing $@.", 
  nameNode, "uses", outerLoop, "for statement"