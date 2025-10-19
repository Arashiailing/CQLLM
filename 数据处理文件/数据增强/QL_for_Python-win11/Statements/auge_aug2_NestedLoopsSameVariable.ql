/**
 * @name Nested loops with same variable
 * @description Identifies nested for-loops that reuse the same iteration variable,
 *              which may cause unexpected behavior and hard-to-diagnose bugs.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Main detection logic: Find problematic nested loop patterns
from For innerForLoop, For outerForLoop, Variable reusedVariable
where 
  // Ensure inner loop is directly nested within outer loop's body
  outerForLoop.getBody().contains(innerForLoop) and
  // Verify both loops target the same iteration variable
  innerForLoop.getTarget().defines(reusedVariable) and
  outerForLoop.getTarget().defines(reusedVariable) and
  // Confirm the variable is referenced in outer scope beyond inner loop
  exists(Name variableReference | 
    variableReference.uses(reusedVariable) and 
    outerForLoop.contains(variableReference) and 
    not innerForLoop.contains(variableReference)
  )
select innerForLoop, 
  "Nested for loop reuses iteration variable '" + reusedVariable.getId() + "' from enclosing $@.", 
  outerForLoop, "for loop"