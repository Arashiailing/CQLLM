/**
 * @name Nested loops with identical iteration variable
 * @description Detects nested for loops that utilize the same iteration variable,
 *              which may lead to unintended behavior and degraded code clarity.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Identifies nested for loops sharing iteration variables where:
// - Both loops target the same variable
// - Inner loop is directly nested in outer loop's body
// - Shared variable is referenced outside inner loop's scope
predicate hasCommonIterationVariable(For innerLoop, For outerLoop, Variable commonVar) {
  // Both loops must define the same iteration variable
  innerLoop.getTarget().defines(commonVar) and
  outerLoop.getTarget().defines(commonVar) and
  // Inner loop must be directly contained in outer loop's body (excluding else clauses)
  outerLoop.getBody().contains(innerLoop) and
  // Variable must be used in outer loop beyond inner loop's context
  exists(Name variableUsage | 
    variableUsage.uses(commonVar) and 
    outerLoop.contains(variableUsage) and 
    not innerLoop.contains(variableUsage)
  )
}

// Query: Find all problematic nested loops with shared iteration variables
from For innerLoop, For outerLoop, Variable commonVar
where hasCommonIterationVariable(innerLoop, outerLoop, commonVar)
select innerLoop, 
  "Nested for loop reuses iteration variable '" + commonVar.getId() + 
  "' from enclosing $@.", 
  outerLoop, 
  "outer for loop"