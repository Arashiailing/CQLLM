/**
 * @name Nested loops with same variable
 * @description Identifies nested for loops that utilize identical iteration variables,
 *              potentially causing code confusion and introducing bugs.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Query to detect problematic nested loop patterns with shared iteration variables
from For innerForLoop, For outerForLoop, Variable reusedVariable
where 
  // Verify inner loop is directly nested within outer loop's body
  outerForLoop.getBody().contains(innerForLoop) and
  // Confirm both loops target the same variable for iteration
  innerForLoop.getTarget().defines(reusedVariable) and
  outerForLoop.getTarget().defines(reusedVariable) and
  // Ensure the variable is referenced in outer scope beyond the inner loop
  exists(Name variableReference | 
    variableReference.uses(reusedVariable) and 
    outerForLoop.contains(variableReference) and 
    not innerForLoop.contains(variableReference)
  )
select innerForLoop, 
  "Nested for loop reuses iteration variable '" + reusedVariable.getId() + "' from enclosing $@.", 
  outerForLoop, "for loop"