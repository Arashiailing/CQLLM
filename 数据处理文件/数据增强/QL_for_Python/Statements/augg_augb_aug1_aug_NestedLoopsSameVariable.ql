/**
 * @name Nested loops reusing iteration variable
 * @description Identifies nested for-loops that utilize the same variable for iteration.
 *              This pattern can lead to the inner loop inadvertently overwriting the outer
 *              loop's iteration variable, potentially causing logical errors and reducing code readability.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Checks if a for-loop statement employs a specific variable as its iteration target
predicate employsIterationVar(For loopStmt, Variable iterVar) { 
  loopStmt.getTarget().defines(iterVar) 
}

// Detects nested loops sharing an iteration variable where the variable
// is referenced outside the inner loop's scope within the outer loop
predicate hasNestedLoopWithSameVar(For innerLoop, For outerLoop, Variable sharedIterVar) {
  // Ensure the inner loop is directly contained within the outer loop's body
  outerLoop.getBody().contains(innerLoop) and
  // Verify both loops use the same iteration variable
  employsIterationVar(innerLoop, sharedIterVar) and
  employsIterationVar(outerLoop, sharedIterVar) and
  // Confirm the variable is accessed in the outer loop beyond the inner loop's scope
  exists(Name varUsage | 
    varUsage.uses(sharedIterVar) and 
    outerLoop.contains(varUsage) and 
    not innerLoop.contains(varUsage)
  )
}

// Main query: Find problematic nested loops with shared iteration variables
from For innerFor, For outerFor, Variable commonVar
where hasNestedLoopWithSameVar(innerFor, outerFor, commonVar)
select innerFor, 
  "Nested for loop reuses iteration variable '" + commonVar.getId() + 
  "' from enclosing $@.", 
  outerFor, 
  "outer for loop"