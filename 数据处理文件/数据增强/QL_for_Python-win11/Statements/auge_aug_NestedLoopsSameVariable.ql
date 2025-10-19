/**
 * @name Nested loops with same variable
 * @description Detects nested loops sharing identical iteration variables, which can cause
 *              logical errors and reduce code maintainability.
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
predicate loopUsesTargetVar(For forStmt, Variable iterVar) { 
  forStmt.getTarget().defines(iterVar) 
}

// Query: Identify problematic nested loops with shared iteration variables
from For innerLoop, For outerLoop, Variable commonVar
where 
  // Verify inner loop is directly nested within outer loop's body (excluding else clauses)
  outerLoop.getBody().contains(innerLoop) and
  // Confirm both loops use identical iteration variable
  loopUsesTargetVar(innerLoop, commonVar) and
  loopUsesTargetVar(outerLoop, commonVar) and
  // Ensure variable is referenced in outer loop scope beyond inner loop
  exists(Name varUsage | 
    varUsage.uses(commonVar) and 
    outerLoop.contains(varUsage) and 
    not innerLoop.contains(varUsage)
  )
select innerLoop, 
  "Nested for loop reuses iteration variable '" + commonVar.getId() + 
  "' from enclosing $@.", 
  outerLoop, 
  "outer for loop"