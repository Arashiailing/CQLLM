/**
 * @name Nested loops with same variable
 * @description Detects nested for-loop constructs that share the same iteration variable,
 *              potentially leading to unintended behavior and debugging challenges.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Main detection logic: Identify problematic nested loop patterns
from For nestedLoop, For enclosingLoop, Variable sharedIterationVar
where 
  // Structural relationship: inner loop is directly nested within outer loop's body
  enclosingLoop.getBody().contains(nestedLoop) and
  // Variable reuse: both loops utilize the same iteration variable
  nestedLoop.getTarget().defines(sharedIterationVar) and
  enclosingLoop.getTarget().defines(sharedIterationVar) and
  // External reference: the variable is used in outer scope beyond inner loop
  exists(Name varUsage | 
    varUsage.uses(sharedIterationVar) and 
    enclosingLoop.contains(varUsage) and 
    not nestedLoop.contains(varUsage)
  )
select nestedLoop, 
  "Nested for loop reuses iteration variable '" + sharedIterationVar.getId() + "' from enclosing $@.", 
  enclosingLoop, "for loop"