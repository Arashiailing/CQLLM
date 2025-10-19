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

// Determines if a for loop uses the specified variable as its iteration target
predicate loopUsesVariable(For loopNode, Variable iterVar) {
  loopNode.getTarget().defines(iterVar)
}

// Finds nested loops where both loops share the same iteration variable,
// and the variable is referenced outside the inner loop's scope
predicate sharedVariableInNestedLoops(For nestedLoop, For enclosingLoop, Variable sharedVar) {
  // Verify both loops utilize the same iteration variable
  loopUsesVariable(nestedLoop, sharedVar) and
  loopUsesVariable(enclosingLoop, sharedVar) and
  // Confirm inner loop is directly nested within outer loop's body (excluding else clauses)
  enclosingLoop.getBody().contains(nestedLoop) and
  // Ensure the variable is used in the outer loop beyond the inner loop's context
  exists(Name varUsage |
    varUsage.uses(sharedVar) and
    enclosingLoop.contains(varUsage) and
    not nestedLoop.contains(varUsage)
  )
}

// Query: Locate all problematic nested loops with shared iteration variables
from For nestedLoop, For enclosingLoop, Variable sharedVar
where sharedVariableInNestedLoops(nestedLoop, enclosingLoop, sharedVar)
select nestedLoop, 
  "Nested for loop reuses iteration variable '" + sharedVar.getId() + 
  "' from enclosing $@.", 
  enclosingLoop, 
  "outer for loop"