/**
 * @name Nested loops with same variable
 * @description Identifies nested for loops that reuse identical iteration variables,
 *              potentially causing unexpected behavior and reducing code readability.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Checks whether a for loop employs the specified variable as its iteration target
predicate loopUsesVariable(For iteration, Variable targetVariable) { 
  iteration.getTarget().defines(targetVariable) 
}

// Detects nested loops where both outer and inner loops share the same iteration variable,
// and the variable is referenced outside the inner loop's scope
predicate sharedVariableInNestedLoops(For innerLoop, For outerLoop, Variable commonVariable) {
  // Verify both loops utilize the same iteration variable
  loopUsesVariable(innerLoop, commonVariable) and
  loopUsesVariable(outerLoop, commonVariable) and
  // Confirm inner loop is directly nested within outer loop's body (excluding else clauses)
  outerLoop.getBody().contains(innerLoop) and
  // Ensure the variable is used in the outer loop beyond the inner loop's context
  exists(Name varUsage | 
    varUsage.uses(commonVariable) and 
    outerLoop.contains(varUsage) and 
    not innerLoop.contains(varUsage)
  )
}

// Query: Locate all problematic nested loops with shared iteration variables
from For innerLoop, For outerLoop, Variable commonVariable
where sharedVariableInNestedLoops(innerLoop, outerLoop, commonVariable)
select innerLoop, 
  "Nested for loop reuses iteration variable '" + commonVariable.getId() + 
  "' from enclosing $@.", 
  outerLoop, 
  "outer for loop"