/**
 * @name Nested loops reusing iteration variable
 * @description Detects nested for loops where both the outer and inner loops utilize
 *              the same variable as their iteration target. This pattern can lead to
 *              the inner loop unintentionally overwriting the outer loop's variable,
 *              resulting in unexpected program behavior and decreased code readability.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Determines whether a for loop statement employs the specified variable as its iteration target
predicate usesIterationVariable(For loopStmt, Variable targetVar) { 
  loopStmt.getTarget().defines(targetVar) 
}

// Locates nested for loops that share a common iteration variable, where the variable
// is referenced in the outer loop beyond the scope of the inner loop
predicate containsConflictingNestedLoop(For innerFor, For outerFor, Variable conflictingVar) {
  // Verify that the inner loop is directly nested within the body of the outer loop
  outerFor.getBody().contains(innerFor) and
  // Confirm that both loops utilize the same variable for iteration
  usesIterationVariable(innerFor, conflictingVar) and
  usesIterationVariable(outerFor, conflictingVar) and
  // Check that the shared variable is accessed in the outer loop outside the inner loop's scope
  exists(Name varAccess | 
    varAccess.uses(conflictingVar) and 
    outerFor.contains(varAccess) and 
    not innerFor.contains(varAccess)
  )
}

// Main query: Identify problematic nested for loops that share iteration variables
from For innerFor, For outerFor, Variable sharedVar
where containsConflictingNestedLoop(innerFor, outerFor, sharedVar)
select innerFor, 
  "Nested for loop reuses iteration variable '" + sharedVar.getId() + 
  "' from enclosing $@.", 
  outerFor, 
  "outer for loop"