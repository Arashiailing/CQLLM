/**
 * @name Nested loops reusing iteration variable
 * @description Identifies nested for-loops that utilize the same variable for iteration.
 *              This pattern can lead to the inner loop inadvertently overwriting the outer
 *              loop's iteration variable, potentially causing logical errors and reducing code readability.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

/**
 * Detects problematic nested loop patterns where:
 * 1. Inner loop is directly nested within outer loop body
 * 2. Both loops share the same iteration variable
 * 3. The shared variable is referenced in outer loop scope outside inner loop
 */
predicate nestedLoopSharedVariable(For innerLoop, For outerLoop, Variable sharedVar) {
  // Verify inner loop is direct child of outer loop body
  outerLoop.getBody().contains(innerLoop) and
  // Confirm both loops define the same iteration variable
  innerLoop.getTarget().defines(sharedVar) and
  outerLoop.getTarget().defines(sharedVar) and
  // Check variable is used in outer loop outside inner loop context
  exists(Name varUsage |
    varUsage.uses(sharedVar) and
    outerLoop.contains(varUsage) and
    not innerLoop.contains(varUsage)
  )
}

// Main query: Locate nested loops with shared iteration variables
from For innerFor, For outerFor, Variable commonVar
where nestedLoopSharedVariable(innerFor, outerFor, commonVar)
select innerFor, 
  "Nested for loop reuses iteration variable '" + commonVar.getId() + 
  "' from enclosing $@.", 
  outerFor, 
  "outer for loop"