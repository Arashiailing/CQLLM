/**
 * @name Nested loops with same variable
 * @description Identifies nested for loops that share identical iteration variables,
 *              which can lead to logical errors and reduce code maintainability.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Determines if a for loop uses the specified variable as its iteration target
predicate isIterationTarget(For loop, Variable iterVar) { 
  loop.getTarget().defines(iterVar) 
}

// Query: Find nested loops sharing iteration variables with external references
from For nestedLoop, For enclosingLoop, Variable sharedVar
where 
  // Verify nested loop is directly contained within outer loop's body
  enclosingLoop.getBody().contains(nestedLoop) and
  // Confirm both loops use identical iteration variable
  isIterationTarget(nestedLoop, sharedVar) and
  isIterationTarget(enclosingLoop, sharedVar) and
  // Ensure variable is referenced in outer scope beyond inner loop
  exists(Name usage | 
    usage.uses(sharedVar) and 
    enclosingLoop.contains(usage) and 
    not nestedLoop.contains(usage)
  )
select nestedLoop, 
  "Nested for loop reuses iteration variable '" + sharedVar.getId() + 
  "' from enclosing $@.", 
  enclosingLoop, 
  "outer for loop"