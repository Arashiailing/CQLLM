/**
 * @name Nested loops with same variable
 * @description Identifies nested for loops that reuse identical iteration variables,
 *              potentially causing unexpected behavior and reducing code readability.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/nested-loops-with-same-variable
 */

import python

// Determines if a for loop iteration uses the specified variable as its target
predicate loopUsesVariable(For forLoop, Variable iteratedVar) { 
  forLoop.getTarget().defines(iteratedVar) 
}

// Detects problematic nested loops where:
// 1. Both loops share the same iteration variable
// 2. Inner loop is directly nested within outer loop's body
// 3. The shared variable is referenced outside the inner loop's scope
predicate sharedVariableInNestedLoops(For nestedLoop, For enclosingLoop, Variable sharedVar) {
  // Both loops must use the same iteration variable
  loopUsesVariable(nestedLoop, sharedVar) and
  loopUsesVariable(enclosingLoop, sharedVar) and
  // Inner loop must be directly contained in outer loop's body (excluding else clauses)
  enclosingLoop.getBody().contains(nestedLoop) and
  // Variable must be used in outer loop beyond inner loop's context
  exists(Name variableUsage | 
    variableUsage.uses(sharedVar) and 
    enclosingLoop.contains(variableUsage) and 
    not nestedLoop.contains(variableUsage)
  )
}

// Query: Identify all problematic nested loops with shared iteration variables
from For nestedLoop, For enclosingLoop, Variable sharedVar
where sharedVariableInNestedLoops(nestedLoop, enclosingLoop, sharedVar)
select nestedLoop, 
  "Nested for loop reuses iteration variable '" + sharedVar.getId() + 
  "' from enclosing $@.", 
  enclosingLoop, 
  "outer for loop"