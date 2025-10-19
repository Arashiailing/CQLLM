/**
 * @name Nested loops with same variable
 * @description Detects nested for-loop structures that utilize identical iteration variables,
 *              which may lead to unintended runtime behavior and degraded code maintainability.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Checks whether a for-loop statement employs the specified variable as its iteration target
predicate checkLoopUsesVariable(For currentLoop, Variable targetVariable) { 
  currentLoop.getTarget().defines(targetVariable) 
}

// Finds instances of nested loops where both the enclosing and enclosed loops
// utilize the same iteration variable, and that variable is referenced in the outer scope
predicate findNestedLoopsWithSharedVar(For innerLoop, For outerLoop, Variable commonVariable) {
  // Ensure the inner loop is directly contained within the outer loop's body (excluding else blocks)
  outerLoop.getBody().contains(innerLoop) and
  // Verify both loops are using the same iteration variable
  checkLoopUsesVariable(innerLoop, commonVariable) and
  checkLoopUsesVariable(outerLoop, commonVariable) and
  // Confirm the variable is referenced in the outer loop outside the inner loop's context
  exists(Name variableReference | 
    variableReference.uses(commonVariable) and 
    outerLoop.contains(variableReference) and 
    not innerLoop.contains(variableReference)
  )
}

// Main query: Identify all problematic nested loop structures with shared iteration variables
from For innerLoop, For outerLoop, Variable commonVariable
where findNestedLoopsWithSharedVar(innerLoop, outerLoop, commonVariable)
select innerLoop, 
  "Nested for loop reuses iteration variable '" + commonVariable.getId() + 
  "' from enclosing $@.", 
  outerLoop, 
  "outer for loop"