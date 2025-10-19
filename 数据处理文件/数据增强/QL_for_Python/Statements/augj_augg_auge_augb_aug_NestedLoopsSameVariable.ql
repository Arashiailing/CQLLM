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

// Identifies problematic nested loops where:
// - Both loops define identical iteration variables
// - Inner loop is directly nested in outer loop's body
// - Shared variable is referenced outside inner loop's scope
predicate hasCommonIterationVariable(For nestedLoop, For enclosingLoop, Variable sharedVar) {
  // Condition 1: Both loops define the same iteration variable
  nestedLoop.getTarget().defines(sharedVar) and
  enclosingLoop.getTarget().defines(sharedVar) and
  
  // Condition 2: Inner loop is directly contained in outer loop's body
  enclosingLoop.getBody().contains(nestedLoop) and
  
  // Condition 3: Variable is used in outer loop beyond inner loop's context
  exists(Name variableUsage | 
    variableUsage.uses(sharedVar) and 
    enclosingLoop.contains(variableUsage) and 
    not nestedLoop.contains(variableUsage)
  )
}

// Query: Find all nested loops reusing iteration variables
from For nestedLoop, For enclosingLoop, Variable sharedVar
where hasCommonIterationVariable(nestedLoop, enclosingLoop, sharedVar)
select nestedLoop, 
  "Nested for loop reuses iteration variable '" + sharedVar.getId() + 
  "' from enclosing $@.", 
  enclosingLoop, 
  "outer for loop"