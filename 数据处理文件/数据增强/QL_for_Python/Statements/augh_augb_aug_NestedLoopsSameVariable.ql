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
predicate loopUsesIterationVar(For loopStmt, Variable iterationVar) { 
  loopStmt.getTarget().defines(iterationVar) 
}

// Identifies nested loops where both outer and inner loops share the same iteration variable,
// and the variable is referenced outside the inner loop's scope
predicate hasSharedIterationVar(For inner, For outer, Variable sharedVar) {
  // Verify inner loop is directly nested within outer loop's body (excluding else clauses)
  outer.getBody().contains(inner) and
  // Confirm both loops utilize the same iteration variable
  loopUsesIterationVar(inner, sharedVar) and
  loopUsesIterationVar(outer, sharedVar) and
  // Ensure the variable is used in the outer loop beyond the inner loop's context
  exists(Name varUsage | 
    varUsage.uses(sharedVar) and 
    outer.contains(varUsage) and 
    not inner.contains(varUsage)
  )
}

// Query: Locate all problematic nested loops with shared iteration variables
from For innerLoop, For outerLoop, Variable sharedVar
where hasSharedIterationVar(innerLoop, outerLoop, sharedVar)
select innerLoop, 
  "Nested for loop reuses iteration variable '" + sharedVar.getId() + 
  "' from enclosing $@.", 
  outerLoop, 
  "outer for loop"