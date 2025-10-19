/**
 * @name Nested loops reusing the same iteration variable
 * @description Finds nested for loops that share the same iteration variable. This can lead to
 *              unexpected behavior because the inner loop will overwrite the variable used by the
 *              outer loop, and it also reduces code readability.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Identifies nested loops sharing the same iteration variable where the variable is referenced
// outside the inner loop's scope within the outer loop
predicate nestedLoopsWithSameVariable(For innerForLoop, For outerForLoop, Variable sharedIterationVar) {
  // Verify inner loop is directly nested in outer loop's body (excluding else clauses)
  outerForLoop.getBody().contains(innerForLoop) and
  // Confirm both loops use the same iteration variable
  innerForLoop.getTarget().defines(sharedIterationVar) and
  outerForLoop.getTarget().defines(sharedIterationVar) and
  // Ensure the variable is used in the outer loop beyond the inner loop's scope
  exists(Name usage | 
    usage.uses(sharedIterationVar) and 
    outerForLoop.contains(usage) and 
    not innerForLoop.contains(usage)
  )
}

// Query: Detect problematic nested loops with shared iteration variables
from For innerForLoop, For outerForLoop, Variable sharedIterationVar
where nestedLoopsWithSameVariable(innerForLoop, outerForLoop, sharedIterationVar)
select innerForLoop, 
  "Nested for loop reuses iteration variable '" + sharedIterationVar.getId() + 
  "' from enclosing $@.", 
  outerForLoop, 
  "outer for loop"