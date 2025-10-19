/**
 * @name Nested loops with same variable
 * @description Identifies nested loops using identical target variables, which can lead to 
 *              confusing behavior due to variable shadowing and unexpected state changes.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Determines if a loop uses a specific variable as its iteration target
predicate loop_variable(For loopStmt, Variable iterationVar) { 
  loopStmt.getTarget().defines(iterationVar) 
}

// Identifies problematic nested loops where:
// 1. Inner loop is directly nested in outer loop's body (excluding else clauses)
// 2. Both loops use the same iteration variable
// 3. The shared variable is referenced in the outer loop outside the inner loop
predicate variableUsedInNestedLoops(For innerLoop, For outerLoop, Variable sharedVar) {
  // Ensure inner loop is directly contained in outer loop's body
  outerLoop.getBody().contains(innerLoop) and
  // Verify both loops use the same iteration variable
  loop_variable(innerLoop, sharedVar) and
  loop_variable(outerLoop, sharedVar) and
  // Confirm shared variable is used in outer loop outside inner loop context
  exists(Name usageNode | 
    usageNode.uses(sharedVar) and 
    outerLoop.contains(usageNode) and 
    not innerLoop.contains(usageNode)
  )
}

// Main query to detect and report problematic nested loops
from For innerLoop, For outerLoop, Variable sharedVar
where variableUsedInNestedLoops(innerLoop, outerLoop, sharedVar)
select innerLoop, 
  "Nested for statement reuses loop variable '" + sharedVar.getId() + 
  "' from enclosing $@.", outerLoop, "for statement"