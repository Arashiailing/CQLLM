/**
 * @name Nested loops reusing the same iteration variable
 * @description Identifies nested loops that use the same variable for iteration, potentially causing
 *              unexpected behavior and making the code harder to understand.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

from For innerLoop, For outerLoop, Variable sharedVar
where
  // Verify inner loop is directly nested in outer loop's body (excluding else clauses)
  outerLoop.getBody().contains(innerLoop) and
  // Confirm both loops use the same iteration variable
  innerLoop.getTarget().defines(sharedVar) and
  outerLoop.getTarget().defines(sharedVar) and
  // Ensure the variable is used in the outer loop beyond the inner loop's scope
  exists(Name varUsage | 
    varUsage.uses(sharedVar) and 
    outerLoop.contains(varUsage) and 
    not innerLoop.contains(varUsage)
  )
select innerLoop, 
  "Nested for loop reuses iteration variable '" + sharedVar.getId() + 
  "' from enclosing $@.", 
  outerLoop, 
  "outer for loop"