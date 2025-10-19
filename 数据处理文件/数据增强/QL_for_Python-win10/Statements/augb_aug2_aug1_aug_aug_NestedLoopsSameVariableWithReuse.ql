/**
 * @name Reuse of loop variable in nested loops after inner loop redefinition
 * @description Identifies scenarios where a loop variable is redefined in an inner loop
 *              and then used in the outer loop, which can cause unintended behavior.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/nested-loops-with-same-variable-reused
 */

import python

// Identifies nested loop scenarios where a variable is reused after being redefined in an inner loop
predicate findNestedLoopVarReuse(For innerForStmt, For outerForStmt, Variable loopVariable, Name varReference) {
  // Verify the structural relationship: inner loop is directly nested in outer loop's body
  outerForStmt.getBody().contains(innerForStmt) and 
  
  // Check variable usage pattern: used in outer loop but not in inner loop
  outerForStmt.contains(varReference) and 
  not innerForStmt.contains(varReference) and 
  
  // Validate SSA variable relationships between loops
  exists(SsaVariable innerSsaDefinition |
    // Confirm inner loop redefines the variable
    innerForStmt.getTarget().getAFlowNode() = innerSsaDefinition.getAnUltimateDefinition().getDefinition() and 
    loopVariable = innerSsaDefinition.getVariable() and 
    
    // Ensure outer loop also uses the same variable
    exists(SsaVariable outerSsaDefinition |
      outerForStmt.getTarget().getAFlowNode() = outerSsaDefinition.getDefinition() and 
      loopVariable = outerSsaDefinition.getVariable()
    ) and 
    
    // Link the variable usage to its SSA definition
    innerSsaDefinition.getAUse().getNode() = varReference
  )
}

// Main query: Detect problematic patterns of nested loop variable reuse
from For innerForStmt, For outerForStmt, Variable loopVariable, Name varReference
where findNestedLoopVarReuse(innerForStmt, outerForStmt, loopVariable, varReference)
select innerForStmt, "Nested for statement $@ loop variable '" + loopVariable.getId() + "' of enclosing $@.", 
       varReference, "uses", outerForStmt, "for statement"