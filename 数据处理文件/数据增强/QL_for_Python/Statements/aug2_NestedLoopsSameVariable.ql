/**
 * @name Nested loops with same variable
 * @description Detects nested loops sharing identical target variables,
 *              which can lead to confusing behavior and potential bugs.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Main query logic: Identify problematic nested loop patterns
from For innerLoop, For outerLoop, Variable sharedVar
where 
  // Verify inner loop is directly nested within outer loop's body
  outerLoop.getBody().contains(innerLoop) and
  // Confirm both loops use the same variable as iteration target
  innerLoop.getTarget().defines(sharedVar) and
  outerLoop.getTarget().defines(sharedVar) and
  // Ensure variable is referenced in outer scope beyond inner loop
  exists(Name varUsage | 
    varUsage.uses(sharedVar) and 
    outerLoop.contains(varUsage) and 
    not innerLoop.contains(varUsage)
  )
select innerLoop, 
  "Nested for loop reuses iteration variable '" + sharedVar.getId() + "' from enclosing $@.", 
  outerLoop, "for loop"