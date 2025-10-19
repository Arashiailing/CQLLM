/**
 * @name Nested loops with same variable
 * @description Identifies nested for loops that reuse identical iteration variables,
 *              which may introduce logical errors and reduce code clarity.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Checks whether a for loop uses the specified variable as its iteration target
predicate loopUsesTargetVar(For loopStmt, Variable var) { 
  loopStmt.getTarget().defines(var) 
}

// Query: Find nested loops sharing iteration variables with external references
from For nestedLoop, For enclosingLoop, Variable sharedVar
where 
  // Ensure inner loop is directly nested within outer loop's body (excluding else branches)
  enclosingLoop.getBody().contains(nestedLoop) and
  // Verify both loops utilize the same iteration variable
  loopUsesTargetVar(nestedLoop, sharedVar) and
  loopUsesTargetVar(enclosingLoop, sharedVar) and
  // Confirm variable is referenced in outer scope beyond inner loop boundaries
  exists(Name varUsage | 
    varUsage.uses(sharedVar) and 
    enclosingLoop.contains(varUsage) and 
    not nestedLoop.contains(varUsage)
  )
select nestedLoop, 
  "Nested for loop reuses iteration variable '" + sharedVar.getId() + 
  "' from enclosing $@.", 
  enclosingLoop, 
  "outer for loop"