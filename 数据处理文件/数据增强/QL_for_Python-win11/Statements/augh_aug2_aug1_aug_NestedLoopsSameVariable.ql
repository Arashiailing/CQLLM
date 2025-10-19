/**
 * @name Nested loops reusing iteration variable
 * @description Identifies nested loops where both inner and outer loops utilize the same iteration variable.
 *              This pattern can cause the inner loop to overwrite the outer loop's variable,
 *              resulting in unexpected behavior and diminished code maintainability.
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
  // Verify direct nesting relationship between loops
  outerLoop.getBody().contains(innerLoop) and
  // Confirm shared iteration variable usage in both loops
  innerLoop.getTarget().defines(sharedVar) and
  outerLoop.getTarget().defines(sharedVar) and
  // Validate variable access outside inner loop scope
  exists(Name varRef | 
    varRef.uses(sharedVar) and 
    outerLoop.contains(varRef) and 
    not innerLoop.contains(varRef)
  )
select innerLoop, 
  "Nested for loop reuses iteration variable '" + sharedVar.getId() + 
  "' from enclosing $@.", 
  outerLoop, 
  "outer for loop"