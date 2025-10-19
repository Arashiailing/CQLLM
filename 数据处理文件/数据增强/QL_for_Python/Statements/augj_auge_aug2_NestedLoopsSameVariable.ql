/**
 * @name Nested loops with same variable
 * @description Detects nested for-loop constructs where both loops utilize the identical iteration variable.
 *              This pattern can lead to variable shadowing, unintended behavior, and bugs that are
 *              difficult to trace during debugging.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Core detection logic: Identify problematic nested loop patterns
from For nestedLoop, For enclosingLoop, Variable sharedIterationVar
where 
  // Verify direct nesting relationship between loops
  enclosingLoop.getBody().contains(nestedLoop) and
  // Confirm both loops target the same iteration variable
  nestedLoop.getTarget().defines(sharedIterationVar) and
  enclosingLoop.getTarget().defines(sharedIterationVar) and
  // Ensure the variable is referenced in outer scope beyond inner loop
  exists(Name varUsageOutsideInnerLoop | 
    varUsageOutsideInnerLoop.uses(sharedIterationVar) and 
    enclosingLoop.contains(varUsageOutsideInnerLoop) and 
    not nestedLoop.contains(varUsageOutsideInnerLoop)
  )
select nestedLoop, 
  "Nested for loop reuses iteration variable '" + sharedIterationVar.getId() + "' from enclosing $@.", 
  enclosingLoop, "for loop"