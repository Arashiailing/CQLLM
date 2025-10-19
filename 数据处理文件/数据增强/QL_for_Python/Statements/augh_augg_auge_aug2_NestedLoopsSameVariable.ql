/**
 * @name Nested loops with same variable
 * @description Identifies nested for-loop structures where both loops utilize the same iteration variable,
 *              which can cause unexpected behavior and make debugging more difficult.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Core detection logic: Find nested for-loops sharing iteration variables
from For innerLoop, For outerLoop, Variable commonVar
where 
  // Establish containment relationship: inner loop is within outer loop's body
  outerLoop.getBody().contains(innerLoop) and
  // Check variable sharing: both loops define the same iteration variable
  innerLoop.getTarget().defines(commonVar) and
  outerLoop.getTarget().defines(commonVar) and
  // Verify external usage: the variable is referenced outside the inner loop
  // but within the scope of the outer loop
  exists(Name varRef | 
    varRef.uses(commonVar) and 
    outerLoop.contains(varRef) and 
    not innerLoop.contains(varRef)
  )
select innerLoop, 
  "Nested for loop reuses iteration variable '" + commonVar.getId() + "' from enclosing $@.", 
  outerLoop, "for loop"