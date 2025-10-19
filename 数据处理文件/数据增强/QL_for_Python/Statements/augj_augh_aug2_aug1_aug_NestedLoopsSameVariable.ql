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

from For nestedLoop, For enclosingLoop, Variable reusedVar
where 
  // Establish direct nesting relationship between loops
  enclosingLoop.getBody().contains(nestedLoop) and
  // Verify both loops define the same iteration variable
  nestedLoop.getTarget().defines(reusedVar) and
  enclosingLoop.getTarget().defines(reusedVar) and
  // Check for variable usage outside inner loop scope but within outer loop
  // This indicates potential interference between loop iterations
  exists(Name variableAccess | 
    variableAccess.uses(reusedVar) and 
    enclosingLoop.contains(variableAccess) and 
    not nestedLoop.contains(variableAccess)
  )
select nestedLoop, 
  "Nested for loop reuses iteration variable '" + reusedVar.getId() + 
  "' from enclosing $@.", 
  enclosingLoop, 
  "outer for loop"