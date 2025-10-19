/**
 * @name Nested loops reusing iteration variable
 * @description Identifies instances where nested for loops utilize the same variable
 *              for iteration in both the outer and inner loops. This pattern can lead
 *              to the inner loop inadvertently modifying the outer loop's iteration variable,
 *              causing logical errors and reducing code readability.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Checks if a for loop statement uses a specific variable as its iteration target
predicate hasIterationVariable(For loopStmt, Variable iterationVar) { 
  loopStmt.getTarget().defines(iterationVar) 
}

// Detects nested for loops that share the same iteration variable, where the variable
// is also referenced in the outer loop outside the inner loop's scope
predicate hasNestedLoopWithSameIterator(For innerLoop, For outerLoop, Variable sharedIterator) {
  // Ensure the inner loop is directly nested within the outer loop's body
  outerLoop.getBody().contains(innerLoop) and
  // Verify both loops use the same variable for iteration
  hasIterationVariable(innerLoop, sharedIterator) and
  hasIterationVariable(outerLoop, sharedIterator) and
  // Check that the shared variable is used in the outer loop outside the inner loop's context
  exists(Name variableUsage | 
    variableUsage.uses(sharedIterator) and 
    outerLoop.contains(variableUsage) and 
    not innerLoop.contains(variableUsage)
  )
}

// Main query: Find nested for loops that problematicly reuse the same iteration variable
from For innerForLoop, For outerForLoop, Variable commonIterator
where hasNestedLoopWithSameIterator(innerForLoop, outerForLoop, commonIterator)
select innerForLoop, 
  "Nested for loop reuses iteration variable '" + commonIterator.getId() + 
  "' from enclosing $@.", 
  outerForLoop, 
  "outer for loop"