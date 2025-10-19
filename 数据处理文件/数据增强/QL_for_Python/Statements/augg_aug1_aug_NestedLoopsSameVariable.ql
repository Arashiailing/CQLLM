/**
 * @name Nested loops sharing iteration variable
 * @description Detects nested loops where the same variable is used as the iteration target in both
 *              the outer and inner loops. This practice can lead to the inner loop overwriting the
 *              outer loop's iteration variable, causing potential bugs and making the code harder to understand.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Determines if a loop uses the specified variable as its iteration target
predicate usesIterationVariable(For currentLoop, Variable iterVar) {
  currentLoop.getTarget().defines(iterVar)
}

// Identifies nested loops with conflicting iteration variables
predicate hasNestedLoopWithSameIterator(For innerLoop, For outerLoop, Variable commonIterVar) {
  // Check nesting relationship
  outerLoop.getBody().contains(innerLoop) and
  // Verify both loops use the same iteration variable
  usesIterationVariable(innerLoop, commonIterVar) and
  usesIterationVariable(outerLoop, commonIterVar) and
  // Confirm the variable is referenced in the outer loop beyond the inner loop's scope
  exists(Name varReference |
    varReference.uses(commonIterVar) and
    outerLoop.contains(varReference) and
    not innerLoop.contains(varReference)
  )
}

// Query: Find problematic nested loops sharing iteration variables
from For innerLoop, For outerLoop, Variable commonIterVar
where hasNestedLoopWithSameIterator(innerLoop, outerLoop, commonIterVar)
select innerLoop,
  "Nested for loop reuses iteration variable '" + commonIterVar.getId() +
  "' from enclosing $@.",
  outerLoop,
  "outer for loop"