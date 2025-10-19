/**
 * @name Nested loops with same variable
 * @description Identifies nested for-loops that utilize identical iteration variables,
 *              potentially causing code confusion and unexpected runtime behavior.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Query to detect nested loops sharing the same iteration variable
from For nestedLoop, For enclosingLoop, Variable commonVar
where 
  // Check that the nested loop is contained within the enclosing loop's body
  enclosingLoop.getBody().contains(nestedLoop) and
  // Verify both loops define and use the same variable for iteration
  nestedLoop.getTarget().defines(commonVar) and
  enclosingLoop.getTarget().defines(commonVar) and
  // Ensure the variable is referenced outside the nested loop but within the enclosing loop
  exists(Name varReference | 
    varReference.uses(commonVar) and 
    enclosingLoop.contains(varReference) and 
    not nestedLoop.contains(varReference)
  )
select nestedLoop, 
  "Nested for loop reuses iteration variable '" + commonVar.getId() + "' from enclosing $@.", 
  enclosingLoop, "for loop"