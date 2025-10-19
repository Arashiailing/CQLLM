/**
 * @name Nested loops reusing the same iteration variable
 * @description Identifies nested loops that use the same variable for iteration, potentially causing
 *              unexpected behavior and making the code harder to understand.
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
predicate hasTargetVariable(For loop, Variable iterationVar) { 
  loop.getTarget().defines(iterationVar) 
}

// Finds nested loops sharing the same iteration variable where the variable is referenced
// outside the inner loop's scope within the outer loop
predicate hasSharedVariableInNestedLoops(For innerLoop, For outerLoop, Variable commonVar) {
  // Verify inner loop is directly nested in outer loop's body (excluding else clauses)
  outerLoop.getBody().contains(innerLoop) and
  // Confirm both loops use the same iteration variable
  hasTargetVariable(innerLoop, commonVar) and
  hasTargetVariable(outerLoop, commonVar) and
  // Ensure the variable is used in the outer loop beyond the inner loop's scope
  exists(Name usage | 
    usage.uses(commonVar) and 
    outerLoop.contains(usage) and 
    not innerLoop.contains(usage)
  )
}

// Query: Detect problematic nested loops with shared iteration variables
from For innerLoop, For outerLoop, Variable commonVar
where hasSharedVariableInNestedLoops(innerLoop, outerLoop, commonVar)
select innerLoop, 
  "Nested for loop reuses iteration variable '" + commonVar.getId() + 
  "' from enclosing $@.", 
  outerLoop, 
  "outer for loop"