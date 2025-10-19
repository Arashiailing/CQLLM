/**
 * @name Nested loops reusing iteration variable
 * @description Detects nested loops where both outer and inner loops utilize identical variables
 *              as their iteration target. This practice may cause the inner loop to overwrite
 *              the outer loop's variable, resulting in unexpected behavior and diminished code clarity.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Determines whether a specified loop employs a given variable as its iteration target
predicate usesIterationTarget(For currentLoop, Variable targetVar) { 
  currentLoop.getTarget().defines(targetVar) 
}

// Identifies nested loops sharing an iteration variable where the variable
// is accessed outside the inner loop's scope
predicate containsConflictingNestedLoop(For nestedFor, For enclosingFor, Variable conflictingVar) {
  // Verify the inner loop is directly contained within the outer loop's body
  enclosingFor.getBody().contains(nestedFor) and
  // Confirm both loops utilize the same iteration variable
  usesIterationTarget(nestedFor, conflictingVar) and
  usesIterationTarget(enclosingFor, conflictingVar) and
  // Ensure the variable is referenced in the outer loop beyond the inner loop's scope
  exists(Name varRef | 
    varRef.uses(conflictingVar) and 
    enclosingFor.contains(varRef) and 
    not nestedFor.contains(varRef)
  )
}

// Query: Locate problematic nested loops with shared iteration variables
from For nestedLoop, For enclosingLoop, Variable sharedVar
where containsConflictingNestedLoop(nestedLoop, enclosingLoop, sharedVar)
select nestedLoop, 
  "Nested for loop reuses iteration variable '" + sharedVar.getId() + 
  "' from enclosing $@.", 
  enclosingLoop, 
  "outer for loop"