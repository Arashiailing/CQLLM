/**
 * @name Nested loops reusing identical iteration variable
 * @description Identifies nested for-loops that utilize the same iteration variable,
 *              potentially causing unintended behavior and reducing code clarity.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Detects nested loops sharing identical iteration variables where the variable
// is referenced outside the inner loop's scope within the outer loop context
predicate sharesVariableInNestedLoops(For innerLoop, For outerLoop, Variable commonVar) {
  // Verify inner loop is directly nested in outer loop's body (excluding else blocks)
  outerLoop.getBody().contains(innerLoop) and
  // Confirm both loops utilize the same iteration variable
  innerLoop.getTarget().defines(commonVar) and
  outerLoop.getTarget().defines(commonVar) and
  // Validate variable usage exists in outer loop beyond inner loop's scope
  exists(Name varRef | 
    varRef.uses(commonVar) and 
    outerLoop.contains(varRef) and 
    not innerLoop.contains(varRef)
  )
}

// Query: Locate problematic nested loops with shared iteration variables
from For innerLoop, For outerLoop, Variable commonVar
where sharesVariableInNestedLoops(innerLoop, outerLoop, commonVar)
select innerLoop, 
  "Nested for loop reuses iteration variable '" + commonVar.getId() + 
  "' from enclosing $@.", 
  outerLoop, 
  "outer for loop"