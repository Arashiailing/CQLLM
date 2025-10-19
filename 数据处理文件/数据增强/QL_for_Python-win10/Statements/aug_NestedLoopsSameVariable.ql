/**
 * @name Nested loops with same variable
 * @description Detects nested loops sharing identical target variables, which can lead to
 *              unexpected behavior and reduced code clarity.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Determines if a given loop uses the specified variable as its iteration target
predicate loopUsesVariable(For loop, Variable targetVar) { 
  loop.getTarget().defines(targetVar) 
}

// Identifies nested loops where the same variable is used in both outer and inner loops,
// and the variable is referenced outside the inner loop scope
predicate sharedVariableInNestedLoops(For nestedLoop, For enclosingLoop, Variable sharedVar) {
  // Ensure inner loop is directly nested within outer loop's body (excluding else clauses)
  enclosingLoop.getBody().contains(nestedLoop) and
  // Verify both loops use the same target variable
  loopUsesVariable(nestedLoop, sharedVar) and
  loopUsesVariable(enclosingLoop, sharedVar) and
  // Confirm the variable is used in the outer loop but not exclusively in the inner loop
  exists(Name usage | 
    usage.uses(sharedVar) and 
    enclosingLoop.contains(usage) and 
    not nestedLoop.contains(usage)
  )
}

// Query: Find all instances of problematic nested loops with shared variables
from For nestedLoop, For enclosingLoop, Variable sharedVar
where sharedVariableInNestedLoops(nestedLoop, enclosingLoop, sharedVar)
select nestedLoop, 
  "Nested for loop reuses iteration variable '" + sharedVar.getId() + 
  "' from enclosing $@.", 
  enclosingLoop, 
  "outer for loop"