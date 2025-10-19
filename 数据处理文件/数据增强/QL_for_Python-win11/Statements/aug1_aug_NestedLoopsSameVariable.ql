/**
 * @name Nested loops reusing iteration variable
 * @description Identifies nested loops where both outer and inner loops use the same variable
 *              as their iteration target. This can cause the inner loop to overwrite the outer
 *              loop's variable, leading to unexpected behavior and reduced code clarity.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Checks if a loop uses the specified variable as its iteration target
predicate isTargetVariable(For loop, Variable iterationVar) { 
  loop.getTarget().defines(iterationVar) 
}

// Finds nested loops sharing the same iteration variable where the variable
// is referenced outside the inner loop's scope
predicate hasConflictingNestedLoop(For innerLoop, For outerLoop, Variable commonVar) {
  // Verify inner loop is directly nested within outer loop's body
  outerLoop.getBody().contains(innerLoop) and
  // Confirm both loops use the same iteration variable
  isTargetVariable(innerLoop, commonVar) and
  isTargetVariable(outerLoop, commonVar) and
  // Ensure the variable is used in outer loop beyond inner loop's scope
  exists(Name variableUsage | 
    variableUsage.uses(commonVar) and 
    outerLoop.contains(variableUsage) and 
    not innerLoop.contains(variableUsage)
  )
}

// Query: Detect problematic nested loops with shared iteration variables
from For nestedLoop, For enclosingLoop, Variable sharedVar
where hasConflictingNestedLoop(nestedLoop, enclosingLoop, sharedVar)
select nestedLoop, 
  "Nested for loop reuses iteration variable '" + sharedVar.getId() + 
  "' from enclosing $@.", 
  enclosingLoop, 
  "outer for loop"