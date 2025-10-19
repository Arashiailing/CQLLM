/**
 * @name Nested loops with same variable
 * @description Detects nested for-loop constructs where both loops utilize the same iteration variable.
 *              This pattern can cause unexpected behavior and increase debugging complexity.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Main detection logic: Identify nested for-loops sharing iteration variables
from For nestedLoop, For enclosingLoop, Variable sharedIterationVar
where 
  // Establish containment: inner loop resides within outer loop's body
  enclosingLoop.getBody().contains(nestedLoop) and
  // Variable sharing verification: both loops define identical iteration variable
  nestedLoop.getTarget().defines(sharedIterationVar) and
  enclosingLoop.getTarget().defines(sharedIterationVar) and
  // External usage validation: variable is referenced outside inner loop
  // but remains within outer loop's scope
  exists(Name variableReference | 
    variableReference.uses(sharedIterationVar) and 
    enclosingLoop.contains(variableReference) and 
    not nestedLoop.contains(variableReference)
  )
select nestedLoop, 
  "Nested for loop reuses iteration variable '" + sharedIterationVar.getId() + "' from enclosing $@.", 
  enclosingLoop, "for loop"