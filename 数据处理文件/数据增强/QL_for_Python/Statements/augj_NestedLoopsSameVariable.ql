/**
 * @name Nested loops with same variable
 * @description Identifies nested loops where the same variable is used as the iteration target
 *              in both loops, making the control flow confusing and error-prone.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Checks if a for loop uses a specific variable as its iteration target
predicate usesVariableAsTarget(For loop, Variable targetVar) {
  loop.getTarget().defines(targetVar)
}

// Identifies problematic nested loops where:
// 1. Inner loop is directly nested within outer loop's body
// 2. Both loops use the same iteration variable
// 3. The variable is referenced in the outer loop (excluding inner loop scope)
predicate hasNestedLoopWithSameVariable(For innerLoop, For outerLoop, Variable sharedVar) {
  // Ensure inner loop is contained within outer loop's body (not else clause)
  outerLoop.getBody().contains(innerLoop) and
  // Verify both loops use the same variable as iteration target
  usesVariableAsTarget(innerLoop, sharedVar) and
  usesVariableAsTarget(outerLoop, sharedVar) and
  // Confirm the variable is actually used in the outer loop scope
  exists(Name nameNode |
    nameNode.uses(sharedVar) and
    outerLoop.contains(nameNode) and
    not innerLoop.contains(nameNode)
  )
}

// Main query: Find all instances of problematic nested loops
from For innerLoop, For outerLoop, Variable sharedVar
where hasNestedLoopWithSameVariable(innerLoop, outerLoop, sharedVar)
select innerLoop, 
  "Nested for loop reuses iteration variable '" + sharedVar.getId() + 
  "' from enclosing $@.", 
  outerLoop, 
  "outer for loop"