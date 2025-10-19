/**
 * @name Nested loops reusing iteration variable
 * @description Identifies nested loops where inner and outer loops utilize the same iteration variable.
 *              This practice can cause the inner loop to overwrite the outer loop's variable,
 *              potentially leading to unintended behavior and reduced code maintainability.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Checks if a loop statement uses the specified variable as its iteration target
predicate isIterationVariable(For loopStmt, Variable iterVar) { 
  loopStmt.getTarget().defines(iterVar) 
}

// Finds nested loops sharing an iteration variable where the variable is accessed
// outside the inner loop's scope within the outer loop's context
predicate nestedLoopWithSharedVar(For innerLoop, For outerLoop, Variable commonVar) {
  // Ensure inner loop is directly nested within outer loop's body
  outerLoop.getBody().contains(innerLoop) and
  // Verify both loops use the same iteration variable
  isIterationVariable(innerLoop, commonVar) and
  isIterationVariable(outerLoop, commonVar) and
  // Confirm variable usage in outer loop beyond inner loop's boundaries
  exists(Name varUsage | 
    varUsage.uses(commonVar) and 
    outerLoop.contains(varUsage) and 
    not innerLoop.contains(varUsage)
  )
}

// Query: Detect problematic nested loops with shared iteration variables
from For innerForLoop, For outerForLoop, Variable iterationVariable
where nestedLoopWithSharedVar(innerForLoop, outerForLoop, iterationVariable)
select innerForLoop, 
  "Nested for loop reuses iteration variable '" + iterationVariable.getId() + 
  "' from enclosing $@.", 
  outerForLoop, 
  "outer for loop"