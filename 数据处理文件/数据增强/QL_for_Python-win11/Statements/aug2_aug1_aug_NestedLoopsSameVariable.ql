/**
 * @name Nested loops reusing iteration variable
 * @description Detects nested loops where inner and outer loops share the same iteration variable.
 *              This practice may cause the inner loop to overwrite the outer loop's variable,
 *              leading to unintended behavior and reduced code maintainability.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Determines if a loop employs the specified variable as its iteration target
predicate usesAsIterationTarget(For iterationLoop, Variable targetVar) { 
  iterationLoop.getTarget().defines(targetVar) 
}

// Identifies nested loops sharing an iteration variable where the variable
// is accessed outside the inner loop's scope
predicate hasNestedLoopWithSharedVariable(For innerIterationLoop, For outerIterationLoop, Variable sharedVariable) {
  // Verify inner loop is directly nested within outer loop's body
  outerIterationLoop.getBody().contains(innerIterationLoop) and
  // Confirm both loops utilize the same iteration variable
  usesAsIterationTarget(innerIterationLoop, sharedVariable) and
  usesAsIterationTarget(outerIterationLoop, sharedVariable) and
  // Validate variable usage in outer loop beyond inner loop's scope
  exists(Name varReference | 
    varReference.uses(sharedVariable) and 
    outerIterationLoop.contains(varReference) and 
    not innerIterationLoop.contains(varReference)
  )
}

// Query: Locate problematic nested loops with shared iteration variables
from For innerForLoop, For outerForLoop, Variable iterationVariable
where hasNestedLoopWithSharedVariable(innerForLoop, outerForLoop, iterationVariable)
select innerForLoop, 
  "Nested for loop reuses iteration variable '" + iterationVariable.getId() + 
  "' from enclosing $@.", 
  outerForLoop, 
  "outer for loop"