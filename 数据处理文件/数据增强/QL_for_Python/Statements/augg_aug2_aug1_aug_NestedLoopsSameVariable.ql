/**
 * @name Nested loops reusing iteration variable
 * @description Identifies nested for loops that share the same iteration variable. This practice
 *              can lead to the inner loop overwriting the outer loop's variable, potentially
 *              causing unintended behavior and reducing code maintainability.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Detects nested loops sharing an iteration variable where the variable is accessed
// outside the inner loop's scope
predicate hasNestedLoopWithSharedVariable(For innerLoop, For outerLoop, Variable commonVar) {
  // Verify inner loop is directly nested within outer loop's body
  outerLoop.getBody().contains(innerLoop) and
  // Confirm both loops utilize the same iteration variable
  innerLoop.getTarget().defines(commonVar) and
  outerLoop.getTarget().defines(commonVar) and
  // Validate variable usage in outer loop beyond inner loop's scope
  exists(Name varUsage |
    varUsage.uses(commonVar) and 
    outerLoop.contains(varUsage) and 
    not innerLoop.contains(varUsage)
  )
}

// Query: Locate problematic nested loops with shared iteration variables
from For innerLoop, For outerLoop, Variable commonVar
where hasNestedLoopWithSharedVariable(innerLoop, outerLoop, commonVar)
select innerLoop, 
  "Nested for loop reuses iteration variable '" + commonVar.getId() + 
  "' from enclosing $@.", 
  outerLoop, 
  "outer for loop"